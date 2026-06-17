import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

enum MonthPickerMode { single, range }

class MonthPicker {
  static Future<DateTime?> showSingleMonthPicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    return showDialog<DateTime>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<AppCubit>(),
        child: MonthPickerDialog(
          mode: MonthPickerMode.single,
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: lastDate,
        ),
      ),
    );
  }

  static Future<DateTimeRange?> showRangeMonthPicker({
    required BuildContext context,
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    return showDialog<DateTimeRange>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<AppCubit>(),
        child: MonthPickerDialog(
          mode: MonthPickerMode.range,
          initialStartDate: initialStartDate,
          initialEndDate: initialEndDate,
          firstDate: firstDate,
          lastDate: lastDate,
        ),
      ),
    );
  }
}

class MonthPickerDialog extends StatefulWidget {
  const MonthPickerDialog({
    required this.mode,
    this.initialDate,
    this.initialStartDate,
    this.initialEndDate,
    this.firstDate,
    this.lastDate,
    super.key,
  });

  final MonthPickerMode mode;
  final DateTime? initialDate;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  State<MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  late DateTime _displayedYear;
  DateTime? _selectedDate;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    if (widget.mode == MonthPickerMode.range) {
      _startDate = widget.initialStartDate;
      _endDate = widget.initialEndDate;
      _displayedYear = _startDate ?? DateTime.now();
    } else {
      _selectedDate = widget.initialDate;
      _displayedYear = _selectedDate ?? DateTime.now();
    }
  }

  void _previousYear() {
    setState(() {
      _displayedYear = DateTime(_displayedYear.year - 1);
    });
  }

  void _nextYear() {
    setState(() {
      _displayedYear = DateTime(_displayedYear.year + 1);
    });
  }

  bool _isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  void _onMonthTapped(DateTime date) {
    if (widget.firstDate != null &&
        date.isBefore(
          DateTime(widget.firstDate!.year, widget.firstDate!.month),
        )) {
      return;
    }
    if (widget.lastDate != null &&
        date.isAfter(DateTime(widget.lastDate!.year, widget.lastDate!.month))) {
      return;
    }

    setState(() {
      if (widget.mode == MonthPickerMode.single) {
        _selectedDate = date;
      } else {
        if (_startDate == null) {
          _startDate = date;
        } else if (_startDate != null && _endDate == null) {
          if (date.isBefore(_startDate!)) {
            _endDate = _startDate;
            _startDate = date;
          } else {
            _endDate = date;
          }
        } else {
          _startDate = date;
          _endDate = null;
        }
      }
    });
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  String _getHeadlineString(BuildContext context, String lang) {
    if (widget.mode == MonthPickerMode.single) {
      if (_selectedDate == null) {
        return context.l10n.monthPickerSelectSingleMonth;
      }
      return _capitalize(DateFormat('MMMM yyyy', lang).format(_selectedDate!));
    } else {
      if (_startDate == null) {
        return context.l10n.monthPickerSelectMultipleMonths;
      }
      final startStr = _capitalize(DateFormat('MMM', lang).format(_startDate!));
      if (_endDate == null) return '$startStr - ';
      final endStr = _capitalize(
        DateFormat('MMM yyyy', lang).format(_endDate!),
      );
      if (_startDate!.year == _endDate!.year) {
        return '$startStr - $endStr';
      } else {
        final startYrStr = _capitalize(
          DateFormat('MMM yyyy', lang).format(_startDate!),
        );
        return '$startYrStr - $endStr';
      }
    }
  }

  Widget _buildMonthCell(BuildContext context, int month, String lang) {
    final date = DateTime(_displayedYear.year, month);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    var isDisabled = false;
    if (widget.firstDate != null &&
        date.isBefore(
          DateTime(widget.firstDate!.year, widget.firstDate!.month),
        )) {
      isDisabled = true;
    }
    if (widget.lastDate != null &&
        date.isAfter(DateTime(widget.lastDate!.year, widget.lastDate!.month))) {
      isDisabled = true;
    }

    final isStart = widget.mode == MonthPickerMode.range &&
        _startDate != null &&
        _isSameMonth(date, _startDate!);
    final isEnd = widget.mode == MonthPickerMode.range &&
        _endDate != null &&
        _isSameMonth(date, _endDate!);
    final isInRange = widget.mode == MonthPickerMode.range &&
        _startDate != null &&
        _endDate != null &&
        date.isAfter(_startDate!) &&
        date.isBefore(_endDate!) &&
        !isStart &&
        !isEnd;
    final isSingleSelected = widget.mode == MonthPickerMode.single &&
        _selectedDate != null &&
        _isSameMonth(date, _selectedDate!);
    final isToday = _isSameMonth(date, DateTime.now());

    final isSelectedCircle = isStart || isEnd || isSingleSelected;

    final Widget circleContent = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelectedCircle ? colorScheme.primary : Colors.transparent,
        border: isToday && !isSelectedCircle
            ? Border.all(color: colorScheme.primary, width: 1.5)
            : null,
      ),
      child: Center(
        child: Text(
          _capitalize(DateFormat('MMM', lang).format(date)),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDisabled
                ? colorScheme.onSurface.withValues(alpha: 0.38)
                : isSelectedCircle
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
            fontVariations: <FontVariation>[
              FontVariation('wght', isToday || isSelectedCircle ? 600 : 100),
            ],
          ),
        ),
      ),
    );

    if (widget.mode == MonthPickerMode.range) {
      final hasRightConnection =
          isStart && _endDate != null && _startDate!.isBefore(_endDate!);
      final hasLeftConnection =
          isEnd && _startDate != null && _startDate!.isBefore(_endDate!);

      return InkResponse(
        onTap: isDisabled ? null : () => _onMonthTapped(date),
        radius: 20,
        child: Stack(
          children: [
            if (hasRightConnection)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: 0.85,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(50),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (hasLeftConnection)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.85,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(50),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (isInRange)
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  color: colorScheme.primaryContainer,
                ),
              ),
            Center(child: circleContent),
          ],
        ),
      );
    }

    return InkResponse(
      onTap: isDisabled ? null : () => _onMonthTapped(date),
      radius: 20,
      child: Center(child: circleContent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = context.select<AppCubit, Locale>(
      (cubit) => cubit.state.language,
    );
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 328,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                top: 24,
                right: 12,
                bottom: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.mode == MonthPickerMode.range
                        ? context.l10n.monthPickerSelectMultipleMonths
                        : context.l10n.monthPickerSelectSingleMonth,
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _getHeadlineString(context, language.toString()),
                          style: textTheme.headlineMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 12,
                top: 8,
                bottom: 8,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      '${_displayedYear.year}',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontVariations: <FontVariation>[
                          const FontVariation('wght', 600),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowLeft01,
                    ),
                    onPressed: _previousYear,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                    ),
                    onPressed: _nextYear,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                height: 220,
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final month = index + 1;
                    return _buildMonthCell(context, month, language.toString());
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      MaterialLocalizations.of(context).cancelButtonLabel,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (widget.mode == MonthPickerMode.range) {
                        if (_startDate != null) {
                          final endMonthDate = _endDate ?? _startDate!;
                          Navigator.of(context).pop(
                            DateTimeRange(
                              start: _startDate!,
                              end: DateTime(
                                endMonthDate.year,
                                endMonthDate.month + 1,
                                0,
                                23,
                                59,
                                59,
                              ),
                            ),
                          );
                        }
                      } else {
                        if (_selectedDate != null) {
                          Navigator.of(context).pop(_selectedDate);
                        }
                      }
                    },
                    child: Text(
                      MaterialLocalizations.of(context).okButtonLabel,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
