import 'package:beecount_business_ui/beecount_business_ui.dart';
import 'package:beecount_ui/beecount_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers.dart';
import '../../../providers/calendar_providers.dart';

class CalendarTransactions extends ConsumerWidget {
  const CalendarTransactions(
      {super.key,
      required this.ledgerId,
      required this.date,
      required this.onAdd});
  final int ledgerId;
  final DateTime date;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context).toString();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      BeeCalendarDayHeading(
          title: DateFormat.MMMMd(locale).format(date),
          weekday: DateFormat.E(locale).format(date),
          addLabel: AppLocalizations.of(context).calendarAddTransaction,
          onAdd: onAdd),
      const SizedBox(height: 10),
      Builder(builder: (context) {
        final totals = ref.watch(dailyTotalsByMonthProvider(
            (ledgerId: ledgerId, month: DateTime(date.year, date.month))));
        return totals.when(
            skipLoadingOnReload: true,
            loading: () => const SizedBox.shrink(),
            error: (e, _) => const SizedBox.shrink(),
            data: (values) {
              double income = 0, expense = 0;
              for (final v in values.values) {
                income += v.$1;
                expense += v.$2;
              }
              final net = income - expense;
              return BeeSurface(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(children: [
                    Text('本月累计',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                                color:
                                    Theme.of(context).colorScheme.onSurface)),
                    const Spacer(),
                    Text('${net >= 0 ? '+' : ''}${net.toStringAsFixed(2)}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: beeTransactionColor(
                                    context,
                                    net >= 0
                                        ? BeeTransactionKind.income
                                        : BeeTransactionKind.expense)))
                  ]));
            });
      })
    ]);
  }
}
