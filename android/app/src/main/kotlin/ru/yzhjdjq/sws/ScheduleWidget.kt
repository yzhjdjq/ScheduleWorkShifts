package ru.yzhjdjq.sws

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.*
import android.os.Build
import android.util.TypedValue
import android.widget.RemoteViews
import androidx.annotation.RequiresApi
import java.time.LocalDate
import org.json.JSONArray
import java.util.*

class ScheduleWidget : AppWidgetProvider() {

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val views = RemoteViews(context.packageName, R.layout.widget_layout)

        val widgetWidth = getWidgetWidth(context, appWidgetId)

        try {
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

            val workShiftsJson = prefs.getString("flutter.workShifts", "[]")
            val shiftSequenceJson = prefs.getString("flutter.shiftSequence", "[]")
            val activeScheduleId = prefs.getString("flutter.activeScheduleId", "")
            val scheduleExceptionsJson = prefs.getString("flutter.scheduleExceptions", "[]")
            val showShiftName = prefs.getBoolean("flutter.showShiftName", true)
            val showShiftNameLegend = prefs.getBoolean("flutter.showShiftNameLegend", false)

            val now = LocalDate.now()
            val year = now.year
            val month = now.monthValue

            views.setTextViewText(R.id.widget_header, formatMonthYear(now))

            buildCalendarTable(
                views = views,
                targetMonth = now,
                workShiftsJson = workShiftsJson,
                shiftSequenceJson = shiftSequenceJson,
                activeScheduleId = activeScheduleId,
                scheduleExceptionsJson = scheduleExceptionsJson,
                showShiftName = showShiftName,
                showShiftNameLegend = showShiftNameLegend,
                today = now.dayOfMonth,
                context = context,
                widgetWidth = widgetWidth
            )

        } catch (e: Exception) {
            e.printStackTrace()
            buildEmptyCalendar(views, context, widgetWidth)
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun formatMonthYear(date: LocalDate): String {
        val monthName = when (date.monthValue) {
            1 -> "Январь"
            2 -> "Февраль"
            3 -> "Март"
            4 -> "Апрель"
            5 -> "Май"
            6 -> "Июнь"
            7 -> "Июль"
            8 -> "Август"
            9 -> "Сентябрь"
            10 -> "Октябрь"
            11 -> "Ноябрь"
            12 -> "Декабрь"
            else -> ""
        }
        return "$monthName ${date.year}"
    }

    private fun buildEmptyCalendar(views: RemoteViews, context: Context, widgetWidth: Int) {
        views.removeAllViews(R.id.calendar_table)
        addWeekHeader(views, context, widgetWidth)
        for (i in 0 until 5) {
            val row = RemoteViews(context.packageName, R.layout.calendar_row)
            repeat(7) { j ->
                setDayCell(row, context, j, "", Color.TRANSPARENT, false, false, widgetWidth)
            }
            views.addView(R.id.calendar_table, row)
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun buildCalendarTable(
        views: RemoteViews,
        targetMonth: LocalDate,
        workShiftsJson: String?,
        shiftSequenceJson: String?,
        activeScheduleId: String?,
        scheduleExceptionsJson: String?,
        showShiftName: Boolean,
        showShiftNameLegend: Boolean,
        today: Int,
        context: Context,
        widgetWidth: Int
    ) {
        views.removeAllViews(R.id.calendar_table)
        addWeekHeader(views, context, widgetWidth) // ✅ Передаём widgetWidth

        val year = targetMonth.year
        val month = targetMonth.monthValue
        val daysInMonth = targetMonth.lengthOfMonth()

        val workShifts = parseWorkShifts(workShiftsJson)
        val shiftSequence = parseShiftSequence(shiftSequenceJson, activeScheduleId)
            .sortedBy { it.orderIndex }
        val exceptions = parseScheduleExceptions(scheduleExceptionsJson, activeScheduleId)

        val firstOfMonth = LocalDate.of(year, month, 1)
        val startDayOfWeek = firstOfMonth.dayOfWeek.getValue()
        val offset = startDayOfWeek - 1

        var currentRow = RemoteViews(context.packageName, R.layout.calendar_row)
        var dayCounter = 0

        repeat(offset) {
            setDayCell(currentRow, context, dayCounter % 7, "", Color.TRANSPARENT, false, false, widgetWidth)
            dayCounter++
        }

        for (day in 1..daysInMonth) {
            if (dayCounter > 0 && dayCounter % 7 == 0) {
                views.addView(R.id.calendar_table, currentRow)
                currentRow = RemoteViews(context.packageName, R.layout.calendar_row)
            }

            val date = LocalDate.of(year, month, day)
            val isToday = day == today

            val shiftInfo = getShiftInfoForDate(
                date = date,
                shiftSequence = shiftSequence,
                workShifts = workShifts,
                exceptions = exceptions
            )

            val dayText = if (showShiftName && shiftInfo.name.isNotEmpty()) {
                "$day\n${getShiftAbbreviation(shiftInfo.name)}"
            } else {
                day.toString()
            }

            setDayCell(currentRow, context, dayCounter % 7, dayText, shiftInfo.color, true, isToday, widgetWidth) // ✅ Передаём widgetWidth
            dayCounter++
        }

        while (dayCounter < 35) {
            if (dayCounter > 0 && dayCounter % 7 == 0) {
                views.addView(R.id.calendar_table, currentRow)
                currentRow = RemoteViews(context.packageName, R.layout.calendar_row)
            }
            setDayCell(currentRow, context, dayCounter % 7, "", Color.TRANSPARENT, false, false, widgetWidth) // ✅
            dayCounter++
        }

        if (dayCounter > 0) {
            views.addView(R.id.calendar_table, currentRow)
        }
    }

    private fun createDayBackgroundBitmap(
        cellWidth: Int,
        cellHeight: Int,
        fillColor: Int,
        isToday: Boolean = false
    ): Bitmap {
        val bitmap = Bitmap.createBitmap(cellWidth, cellHeight, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val paint = Paint().apply {
            isAntiAlias = true
        }

        val cornerRadius = (cellWidth * 0.08f).coerceAtLeast(8f)

        // Фон со скруглёнными углами — всегда
        paint.color = fillColor
        paint.style = Paint.Style.FILL
        canvas.drawRoundRect(
            0f, 0f, cellWidth.toFloat(), cellHeight.toFloat(),
            cornerRadius, cornerRadius, paint
        )

        // Белая обводка — только если сегодня
        if (isToday) {
            paint.color = Color.WHITE
            paint.style = Paint.Style.STROKE
            paint.strokeWidth = 6f
            canvas.drawRoundRect(
                3f, 3f, cellWidth.toFloat() - 6f, cellHeight.toFloat() - 6f,
                cornerRadius, cornerRadius, paint
            )
        }

        return bitmap
    }

    private fun addWeekHeader(views: RemoteViews, context: Context, widgetWidth: Int) {
        val weekDays = arrayOf("ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ", "ВС")
        val headerRow = RemoteViews(context.packageName, R.layout.calendar_row)
        weekDays.forEachIndexed { index, day ->
            setDayCell(headerRow, context, index, day, Color.TRANSPARENT, false, false, widgetWidth) // ✅
        }
        views.addView(R.id.calendar_table, headerRow)
    }

    private fun setDayCell(
        row: RemoteViews,
        context: Context,
        position: Int,
        text: String,
        color: Int,
        isDay: Boolean,
        isToday: Boolean,
        widgetWidth: Int
    ) {
        val containerId = when (position) {
            0 -> R.id.day1_container
            1 -> R.id.day2_container
            2 -> R.id.day3_container
            3 -> R.id.day4_container
            4 -> R.id.day5_container
            5 -> R.id.day6_container
            6 -> R.id.day7_container
            else -> R.id.day1_container
        }

        val bgId = when (position) {
            0 -> R.id.day1_bg
            1 -> R.id.day2_bg
            2 -> R.id.day3_bg
            3 -> R.id.day4_bg
            4 -> R.id.day5_bg
            5 -> R.id.day6_bg
            6 -> R.id.day7_bg
            else -> R.id.day1_bg
        }

        val textId = when (position) {
            0 -> R.id.day1_text
            1 -> R.id.day2_text
            2 -> R.id.day3_text
            3 -> R.id.day4_text
            4 -> R.id.day5_text
            5 -> R.id.day6_text
            6 -> R.id.day7_text
            else -> R.id.day1_text
        }

        row.setTextViewText(textId, text)

        val bgColor = when {
            isDay && color != Color.TRANSPARENT -> color
            isDay -> Color.DKGRAY
            else -> Color.TRANSPARENT
        }

        // --- ВАЖНО: УДАЛЯЕМ ЭТОТ БЛОК ---
        // if (isToday && isDay) { ... } else { setBackgroundColor }

        // ВМЕСТО НЕГО — ВСЕГДА ГЕНЕРИРУЕМ BITMAP СО СКРУГЛЕНИЕМ
        val cellWidth = (widgetWidth / 7).coerceAtLeast(30)
        val cellHeight = (cellWidth * 1.2f).toInt()

        val bitmap = createDayBackgroundBitmap(
            cellWidth = cellWidth,
            cellHeight = cellHeight,
            fillColor = bgColor,
            isToday = isToday  // белая рамка только если сегодня
        )

        row.setImageViewBitmap(bgId, bitmap)
        row.setViewVisibility(bgId, android.view.View.VISIBLE) // всегда VISIBLE

        val textColor = when {
            !isDay -> Color.LTGRAY
            else -> getContrastColor(bgColor)
        }
        row.setTextColor(textId, textColor)

        val textSize = when {
            text.contains("\n") -> 10f
            !isDay -> 10f
            else -> 12f
        }
        row.setTextViewTextSize(textId, TypedValue.COMPLEX_UNIT_SP, textSize)
    }

    private fun getShiftAbbreviation(fullName: String): String {
        return when {
            fullName.contains("день", ignoreCase = true) -> "День"
            fullName.contains("ночь", ignoreCase = true) -> "Ночь"
            fullName.contains("с ночи", ignoreCase = true) -> "С ночи"
            fullName.contains("выходной", ignoreCase = true) -> "Выход"
            else -> fullName.take(2).uppercase()
        }
    }

    private fun getContrastColor(bg: Int): Int {
        val darkness = 1 - (0.299 * Color.red(bg) + 0.587 * Color.green(bg) + 0.114 * Color.blue(bg)) / 255
        return if (darkness < 0.5) Color.BLACK else Color.WHITE
    }

    private fun parseWorkShifts(json: String?): Map<String, WorkShift> {
        val map = mutableMapOf<String, WorkShift>()
        try {
            val arr = JSONArray(json ?: "[]")
            for (i in 0 until arr.length()) {
                val obj = arr.getJSONObject(i)
                map[obj.getString("id")] = WorkShift(
                    id = obj.getString("id"),
                    name = obj.getString("name"),
                    color = obj.getLong("color").toInt()
                )
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return map
    }

    private fun parseShiftSequence(json: String?, scheduleId: String?): List<ShiftSequenceItem> {
        val list = mutableListOf<ShiftSequenceItem>()
        try {
            val arr = JSONArray(json ?: "[]")
            for (i in 0 until arr.length()) {
                val obj = arr.getJSONObject(i)
                if (obj.getString("scheduleId") == scheduleId) {
                    list.add(
                        ShiftSequenceItem(
                            workShiftId = obj.getString("workShiftId"),
                            startDate = obj.getString("startDate"),
                            endDate = obj.getString("endDate"),
                            orderIndex = obj.getInt("orderIndex"),
                            consecutiveDays = obj.optInt("consecutiveDays", 1)
                        )
                    )
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return list
    }

    private fun parseScheduleExceptions(json: String?, scheduleId: String?): List<ScheduleException> {
        val list = mutableListOf<ScheduleException>()
        try {
            val arr = JSONArray(json ?: "[]")
            for (i in 0 until arr.length()) {
                val obj = arr.getJSONObject(i)
                if (obj.getString("scheduleId") == scheduleId) {
                    list.add(
                        ScheduleException(
                            workShiftId = obj.getString("workShiftId"),
                            startDate = obj.getString("startDate"),
                            endDate = obj.getString("endDate")
                        )
                    )
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return list
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun getShiftInfoForDate(
        date: LocalDate,
        shiftSequence: List<ShiftSequenceItem>,
        workShifts: Map<String, WorkShift>,
        exceptions: List<ScheduleException>
    ): ShiftInfo {
        for (exception in exceptions) {
            val start = parseLocalDate(exception.startDate)
            val end = parseLocalDate(exception.endDate)
            if (start != null && end != null && !date.isBefore(start) && !date.isAfter(end)) {
                return when (exception.workShiftId) {
                    "sickLeave" -> ShiftInfo(Color.parseColor("#FFFF6B6B"), "Больничный")
                    "vacation" -> ShiftInfo(Color.parseColor("#FF4ECDC4"), "Отпуск")
                    else -> ShiftInfo(Color.GRAY, "Ошибка")
                }
            }
        }

        if (shiftSequence.isEmpty()) return ShiftInfo(Color.DKGRAY, "")

        val cycleStart = parseLocalDate(shiftSequence.first().startDate)
            ?: return ShiftInfo(Color.DKGRAY, "")

        if (date.isBefore(cycleStart)) return ShiftInfo(Color.DKGRAY, "")

        val daysSinceStart = (date.toEpochDay() - cycleStart.toEpochDay()).toInt() + 1
        if (daysSinceStart <= 0) return ShiftInfo(Color.DKGRAY, "")

        val totalCycleLength = shiftSequence.sumOf { it.consecutiveDays.toLong() }.toInt()
        if (totalCycleLength == 0) return ShiftInfo(Color.DKGRAY, "")

        var positionInCycle = daysSinceStart % totalCycleLength
        if (positionInCycle == 0) positionInCycle = totalCycleLength

        var accumulated = 0
        for (item in shiftSequence) {
            accumulated += item.consecutiveDays
            if (positionInCycle <= accumulated) {
                val shift = workShifts[item.workShiftId]
                return ShiftInfo(shift?.color ?: Color.GRAY, shift?.name ?: "")
            }
        }

        val fallbackShift = workShifts[shiftSequence.first().workShiftId]
        return ShiftInfo(fallbackShift?.color ?: Color.GRAY, fallbackShift?.name ?: "")
    }

    @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR2)
    private fun getWidgetWidth(context: Context, appWidgetId: Int): Int {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
        val minWidthDp = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 200)
        return dpToPx(context, minWidthDp.toFloat())
    }

    private fun dpToPx(context: Context, dp: Float): Int { // ✅ Принимаем Float
        val density = context.resources.displayMetrics.density
        return (dp * density + 0.5f).toInt()
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun parseLocalDate(dateStr: String?): LocalDate? = try {
        LocalDate.parse(dateStr?.substring(0, 10))
    } catch (e: Exception) {
        null
    }

    data class WorkShift(
        val id: String,
        val name: String,
        val color: Int
    )

    data class ShiftSequenceItem(
        val workShiftId: String,
        val startDate: String,
        val endDate: String,
        val orderIndex: Int,
        val consecutiveDays: Int
    )

    data class ScheduleException(
        val workShiftId: String,
        val startDate: String,
        val endDate: String
    )

    data class ShiftInfo(
        val color: Int,
        val name: String
    )
}