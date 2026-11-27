import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../models/islamic_date_info_model.dart';
import '../constants/app_strings.dart';
import '../responsive/responsive_extensions.dart';
import '../responsive/responsive_utils.dart';
import '../theme/app_theme.dart';
import '../utils/islamic_calendar_utils.dart';
import '../utils/urdu_number_utils.dart';

/// Interactive Dual Calendar Bottom Sheet displaying full Gregorian & Lunar (Hijri)
/// monthly dates side by side, special Islamic dates, and moon-sighting offset controls.
class DualCalendarSheet extends StatefulWidget {
  final int initialHijriOffset;
  final bool isUrdu;
  final ValueChanged<int> onOffsetChanged;

  const DualCalendarSheet({
    super.key,
    required this.initialHijriOffset,
    required this.isUrdu,
    required this.onOffsetChanged,
  });

  @override
  State<DualCalendarSheet> createState() => _DualCalendarSheetState();
}

class _DualCalendarSheetState extends State<DualCalendarSheet> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;
  late int _hijriOffset;

  static const List<String> _weekdaysEn = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> _weekdaysUr = <String>[
    'پیر',
    'منگل',
    'بدھ',
    'جمعرات',
    'جمعہ',
    'ہفتہ',
    'اتوار',
  ];

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _focusedMonth = DateTime(now.year, now.month, 1);
    _hijriOffset = widget.initialHijriOffset;
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta, 1);
    });
  }

  void _jumpToToday() {
    final DateTime now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(now.year, now.month, now.day);
      _focusedMonth = DateTime(now.year, now.month, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final IslamicDateInfoModel selectedInfo = IslamicCalendarUtils.getTodayInfo(
      date: _selectedDate,
      hijriDayOffset: _hijriOffset,
    );

    final int daysInMonth =
    DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final int firstWeekdayOffset = _focusedMonth.weekday - 1; // Mon = 0 .. Sun = 6

    final HijriCalendar monthStartHijri = HijriCalendar.fromDate(
      _focusedMonth.add(Duration(days: _hijriOffset)),
    );
    final HijriCalendar monthEndHijri = HijriCalendar.fromDate(
      DateTime(_focusedMonth.year, _focusedMonth.month, daysInMonth)
          .add(Duration(days: _hijriOffset)),
    );

    final String hijriSpanLabel = monthStartHijri.hMonth == monthEndHijri.hMonth
        ? '${monthStartHijri.longMonthName} ${monthStartHijri.hYear} AH'
        : '${monthStartHijri.longMonthName} / ${monthEndHijri.longMonthName} ${monthEndHijri.hYear} AH';

    return SafeArea(
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.sz, 4.sz, 16.sz, 16.sz),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Header Title + Jump to Today
              Row(
                children: <Widget>[
                  Icon(
                    Icons.calendar_month_rounded,
                    color: context.colorScheme.primary,
                    size: 22.sz,
                  ),
                  8.hSpace,
                  Expanded(
                    child: Text(
                      AppStrings.dualCalendarTitle.tr,
                      style: context.textTheme.titleLarge,
                    ),
                  ),
                  TextButton(
                    onPressed: _jumpToToday,
                    child: Text(AppStrings.todayButton.tr),
                  ),
                ],
              ),
              10.vSpace,

              // Selected Date Dual Summary Card
              Container(
                padding: ResponsiveUtils.allPadding(14),
                decoration: BoxDecoration(
                  gradient: context.appColors.heroGradient,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                AppStrings.hijriCalendarLabel.tr,
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: context.appColors.onHeroMuted,
                                ),
                              ),
                              2.vSpace,
                              Text(
                                selectedInfo.formattedHijri(isUrdu: widget.isUrdu),
                                style: context.textTheme.titleMedium?.copyWith(
                                  color: context.appColors.onHeroSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 32.sz,
                          color: context.appColors.onHeroPrimary.withValues(alpha: 0.25),
                        ),
                        12.hSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                AppStrings.gregorianCalendarLabel.tr,
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: context.appColors.onHeroMuted,
                                ),
                              ),
                              2.vSpace,
                              Text(
                                selectedInfo.formattedGregorian(isUrdu: widget.isUrdu),
                                style: context.textTheme.titleMedium?.copyWith(
                                  color: context.appColors.onHeroPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (selectedInfo.hasSpecialOccasion) ...<Widget>[
                      10.vSpace,
                      Container(
                        padding: ResponsiveUtils.symmetricPadding(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: context.appColors.onHeroSecondary.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 15.sz,
                              color: context.appColors.onHeroSecondary,
                            ),
                            6.hSpace,
                            Expanded(
                              child: Text(
                                selectedInfo.localizedOccasionTitle(
                                  isUrdu: widget.isUrdu,
                                ) ??
                                    '',
                                style: context.textTheme.labelMedium?.copyWith(
                                  color: context.appColors.onHeroSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              12.vSpace,

              // Month Switcher Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    onPressed: () => _changeMonth(-1),
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        '${_monthNameEn(_focusedMonth.month)} ${_focusedMonth.year}',
                        style: context.textTheme.titleMedium,
                      ),
                      Text(
                        hijriSpanLabel,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => _changeMonth(1),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
              6.vSpace,

              // Weekday Headers
              Row(
                children: List<Widget>.generate(7, (int index) {
                  final bool isJummah = index == 4;
                  return Expanded(
                    child: Center(
                      child: Text(
                        widget.isUrdu ? _weekdaysUr[index] : _weekdaysEn[index],
                        style: context.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isJummah
                              ? context.colorScheme.primary
                              : context.appColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              8.vSpace,

              // Dual Date Grid (Gregorian Day + Lunar Hijri Day in every cell)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: firstWeekdayOffset + daysInMonth,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 0.92,
                ),
                itemBuilder: (BuildContext context, int index) {
                  if (index < firstWeekdayOffset) {
                    return const SizedBox.shrink();
                  }
                  final int dayNum = index - firstWeekdayOffset + 1;
                  final DateTime cellDate =
                  DateTime(_focusedMonth.year, _focusedMonth.month, dayNum);
                  final HijriCalendar cellHijri = HijriCalendar.fromDate(
                    cellDate.add(Duration(days: _hijriOffset)),
                  );

                  final bool isSelected = DateUtils.isSameDay(cellDate, _selectedDate);
                  final bool isToday = DateUtils.isSameDay(cellDate, DateTime.now());

                  return InkWell(
                    borderRadius: BorderRadius.circular(10.r),
                    onTap: () {
                      setState(() {
                        _selectedDate = cellDate;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.colorScheme.primary
                            : (isToday
                            ? context.colorScheme.primaryContainer
                            : context.appColors.cardBackground),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isToday
                              ? context.colorScheme.primary
                              : context.appColors.border,
                          width: isToday ? 1.4 : 0.8,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '$dayNum',
                            style: context.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? context.colorScheme.onPrimary
                                  : context.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            UrduNumberUtils.format(cellHijri.hDay),
                            style: context.textTheme.labelSmall?.copyWith(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? context.appColors.onHeroSecondary
                                  : context.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              14.vSpace,

              // Moon Sighting Offset Adjuster (-1 / 0 / +1)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    AppStrings.moonSightingAdjustment.tr,
                    style: context.textTheme.labelMedium,
                  ),
                  SegmentedButton<int>(
                    segments: const <ButtonSegment<int>>[
                      ButtonSegment<int>(value: -1, label: Text('-1')),
                      ButtonSegment<int>(value: 0, label: Text('0')),
                      ButtonSegment<int>(value: 1, label: Text('+1')),
                    ],
                    selected: <int>{_hijriOffset},
                    onSelectionChanged: (Set<int> selection) {
                      final int next = selection.first;
                      setState(() {
                        _hijriOffset = next;
                      });
                      widget.onOffsetChanged(next);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthNameEn(int m) {
    const List<String> names = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[(m - 1).clamp(0, 11)];
  }
}