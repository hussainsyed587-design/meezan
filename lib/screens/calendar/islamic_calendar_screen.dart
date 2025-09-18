import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_theme.dart';
import '../../providers/islamic_calendar_provider.dart';
import '../../models/hijri_calendar.dart';
import '../../widgets/islamic_event_card.dart';

class IslamicCalendarScreen extends StatefulWidget {
  const IslamicCalendarScreen({super.key});

  @override
  State<IslamicCalendarScreen> createState() => _IslamicCalendarScreenState();
}

class _IslamicCalendarScreenState extends State<IslamicCalendarScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Initialize Islamic calendar data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<IslamicCalendarProvider>(context, listen: false)
          .getHijriDate(_selectedDay);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Islamic Calendar'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _selectedDay = DateTime.now();
                _focusedDay = DateTime.now();
              });
              Provider.of<IslamicCalendarProvider>(context, listen: false)
                  .getHijriDate(_selectedDay);
            },
            tooltip: 'Go to Today',
          ),
          IconButton(
            icon: const Icon(Icons.event_note),
            onPressed: _showAddEventDialog,
            tooltip: 'Add Event',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Calendar'),
            Tab(text: 'Events'),
            Tab(text: 'Fasting'),
            Tab(text: 'Months'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCalendarView(),
          _buildEventsView(),
          _buildFastingView(),
          _buildMonthsView(),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    return Consumer<IslamicCalendarProvider>(
      builder: (context, calendarProvider, child) {
        return Column(
          children: [
            // Hijri Date Display
            if (calendarProvider.currentHijriDate != null) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.greenGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      calendarProvider.currentHijriDate!.formattedDate,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${calendarProvider.selectedDate.day} ${_getMonthName(calendarProvider.selectedDate.month)} ${calendarProvider.selectedDate.year}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                    if (calendarProvider.currentHijriDate!.events.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.event, color: AppColors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${calendarProvider.currentHijriDate!.events.length} event(s)',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Calendar Widget
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Card(
                      child: TableCalendar<IslamicEvent>(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        eventLoader: (day) => _getEventsForDay(day, calendarProvider),
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          selectedDecoration: const BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: const BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                          weekendTextStyle: const TextStyle(
                            color: AppColors.error,
                          ),
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: true,
                          titleCentered: true,
                          formatButtonShowsNext: false,
                          formatButtonDecoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          ),
                          formatButtonTextStyle: TextStyle(
                            color: AppColors.white,
                          ),
                        ),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                          calendarProvider.selectDate(selectedDay);
                        },
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                      ),
                    ),
                    
                    // Events for selected day
                    if (calendarProvider.currentHijriDate?.events.isNotEmpty == true) ...[
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Events for ${_formatSelectedDate()}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...calendarProvider.currentHijriDate!.events.map(
                                (event) => IslamicEventCard(event: event),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEventsView() {
    return Consumer<IslamicCalendarProvider>(
      builder: (context, calendarProvider, child) {
        final currentMonthEvents = calendarProvider.getEventsForMonth(
          _focusedDay.year,
          _focusedDay.month,
        );

        if (currentMonthEvents.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 64,
                  color: AppColors.mediumGrey,
                ),
                SizedBox(height: 16),
                Text(
                  'No Events This Month',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Add your personal Islamic events',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: currentMonthEvents.length,
          itemBuilder: (context, index) {
            final event = currentMonthEvents[index];
            return IslamicEventCard(
              event: event,
              showDate: true,
            );
          },
        );
      },
    );
  }

  Widget _buildFastingView() {
    return Consumer<IslamicCalendarProvider>(
      builder: (context, calendarProvider, child) {
        final currentMonthFasting = calendarProvider.getFastingDaysForMonth(
          _focusedDay.year,
          _focusedDay.month,
        );

        if (currentMonthFasting.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.no_food,
                  size: 64,
                  color: AppColors.mediumGrey,
                ),
                SizedBox(height: 16),
                Text(
                  'No Recommended Fasting',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Check other months for fasting days',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: currentMonthFasting.length,
          itemBuilder: (context, index) {
            final fasting = currentMonthFasting[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: fasting.isObligatory 
                        ? AppColors.error.withOpacity(0.1)
                        : AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    fasting.isObligatory ? Icons.schedule : Icons.star,
                    color: fasting.isObligatory ? AppColors.error : AppColors.primaryGreen,
                  ),
                ),
                title: Text(
                  fasting.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fasting.description),
                    const SizedBox(height: 4),
                    Text(
                      '${fasting.date.day}/${fasting.date.month}/${fasting.date.year}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    if (fasting.reward != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Reward: ${fasting.reward}',
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: Icon(
                  fasting.type == FastingType.ramadan 
                      ? Icons.star
                      : fasting.type == FastingType.voluntary
                          ? Icons.favorite
                          : Icons.event,
                  color: AppColors.primaryGreen,
                ),
                onTap: () => _showFastingDetails(fasting),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMonthsView() {
    return Consumer<IslamicCalendarProvider>(
      builder: (context, calendarProvider, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: calendarProvider.months.length,
          itemBuilder: (context, index) {
            final month = calendarProvider.months[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryGreen,
                  child: Text(
                    month.monthNumber.toString(),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  month.englishName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  month.arabicName,
                  style: AppTheme.arabicTextStyle(),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          month.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Days: ${month.days}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        if (month.significance.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Text(
                            'Significance:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          ...month.significance.map(
                            (sig) => Padding(
                              padding: const EdgeInsets.only(left: 8, top: 2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(
                                    color: AppColors.primaryGreen,
                                    fontWeight: FontWeight.bold,
                                  )),
                                  Expanded(child: Text(sig)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<IslamicEvent> _getEventsForDay(DateTime day, IslamicCalendarProvider provider) {
    return provider.events.where((event) {
      if (event.isRecurring) {
        return day.month == event.startDate.month && day.day == event.startDate.day;
      } else {
        if (event.endDate != null) {
          return day.isAfter(event.startDate.subtract(const Duration(days: 1))) &&
                 day.isBefore(event.endDate!.add(const Duration(days: 1)));
        } else {
          return isSameDay(day, event.startDate);
        }
      }
    }).toList();
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return month >= 1 && month <= 12 ? monthNames[month - 1] : 'Unknown';
  }

  String _formatSelectedDate() {
    return '${_selectedDay.day} ${_getMonthName(_selectedDay.month)} ${_selectedDay.year}';
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Personal Event'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('This feature will allow you to add personal Islamic events and reminders.'),
            SizedBox(height: 16),
            Text('Coming soon in the next update!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showFastingDetails(FastingDay fasting) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(fasting.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(fasting.description),
              const SizedBox(height: 16),
              if (fasting.reward != null) ...[
                const Text(
                  'Reward:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(fasting.reward!),
                const SizedBox(height: 16),
              ],
              if (fasting.guidelines.isNotEmpty) ...[
                const Text(
                  'Guidelines:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...fasting.guidelines.map(
                  (guideline) => Padding(
                    padding: const EdgeInsets.only(left: 8, top: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(guideline)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}