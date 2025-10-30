part of '../../../ok_mobile_common.dart';

class BaseCalendar extends StatefulWidget {
  const BaseCalendar({
    required this.weekdaysTitles,
    this.defaultBuilder,
    this.outsideBuilder,
    this.onDaySelected,
    super.key,
  });

  final List<String> weekdaysTitles;
  final Widget? Function(BuildContext, DateTime, DateTime)? defaultBuilder;
  final Widget? Function(BuildContext, DateTime, DateTime)? outsideBuilder;
  final void Function(DateTime, DateTime)? onDaySelected;

  @override
  State<BaseCalendar> createState() => _BaseCalendarState();
}

class _BaseCalendarState extends State<BaseCalendar> {
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return TableCalendar<void>(
          onPageChanged: (focusedDay) => setState(() {
            _selectedMonth = focusedDay;
          }),
          startingDayOfWeek: StartingDayOfWeek.monday,
          firstDay: DateTime.now().subtract(const Duration(days: 70)),
          lastDay: DateTime.now(),
          focusedDay: _selectedMonth,
          selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
          onDaySelected: (selectedDay, focusedDay) => setState(() {
            _selectedDate = selectedDay;
            widget.onDaySelected?.call(selectedDay, focusedDay);
          }),
          availableCalendarFormats: const {CalendarFormat.month: 'Month'},
          headerStyle: const HeaderStyle(
            titleCentered: true,
            headerPadding: EdgeInsets.zero,
          ),
          rowHeight: constraints.maxWidth / 7,
          currentDay: _selectedDate,
          daysOfWeekStyle: DaysOfWeekStyle(
            dowTextFormatter: (date, locale) {
              return widget.weekdaysTitles[date.weekday - 1];
            },
          ),
          daysOfWeekHeight: 32,
          calendarBuilders: CalendarBuilders(
            headerTitleBuilder: (context, day) => Text(
              DateFormat.yMMMM().format(day).capitalize(),
              style: Theme.of(
                context,
              ).textTheme.titleSmall!.copyWith(color: AppColors.black),
              textAlign: TextAlign.center,
            ),
            defaultBuilder: widget.defaultBuilder,
            selectedBuilder: (context, day, focusedDay) {
              return Padding(
                padding: const EdgeInsets.all(2),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.darkGrey),
                  ),
                  child: Text(
                    day.day.toString(),
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall!.copyWith(color: AppColors.black),
                  ),
                ),
              );
            },
            disabledBuilder: (context, day, focusedDay) {
              return Padding(
                padding: const EdgeInsets.all(2),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.darkGrey),
                  ),
                  child: Text(
                    day.day.toString(),
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: _selectedMonth.month == day.month
                          ? AppColors.black
                          : AppColors.darkGrey,
                    ),
                  ),
                ),
              );
            },
            outsideBuilder: widget.outsideBuilder,
          ),
        );
      },
    );
  }
}
