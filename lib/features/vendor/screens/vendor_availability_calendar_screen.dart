import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/availability_provider.dart';
import '../models/availability_entry.dart';
import '../repositories/availability_repository.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/wz_loading.dart';

class VendorAvailabilityCalendarScreen extends StatefulWidget {
  const VendorAvailabilityCalendarScreen({super.key});

  @override
  State<VendorAvailabilityCalendarScreen> createState() =>
      _VendorAvailabilityCalendarScreenState();
}

class _VendorAvailabilityCalendarScreenState
    extends State<VendorAvailabilityCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user?.role != 'vendor') {
      return Scaffold(
        appBar: AppBar(title: const Text('Availability Calendar')),
        body: const Center(
          child: Text(
            'This feature is only available for vendors',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => AvailabilityProvider(
        AvailabilityRepository(context.read<ApiService>()),
        authProvider,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Availability Calendar',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFFEF2F55),
          foregroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Consumer<AvailabilityProvider>(
          builder: (context, provider, _) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    calendarFormat: CalendarFormat.month,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      _showEditSheet(context, selectedDay, provider);
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: const Color(0xFFEF2F55).withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Color(0xFFEF2F55),
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: Color(0xFFEF2F55),
                        shape: BoxShape.circle,
                      ),
                      outsideDaysVisible: false,
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        return _buildDayCell(day, provider, false);
                      },
                      todayBuilder: (context, day, focusedDay) {
                        return _buildDayCell(day, provider, true);
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        return _buildDayCell(
                          day,
                          provider,
                          false,
                          isSelected: true,
                        );
                      },
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendItem('Booked', const Color(0xFFEF2F55)),
                      _buildLegendItem('Unavailable', Colors.grey),
                      _buildLegendItem('Available', Colors.white),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if (provider.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: WzLoading(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDayCell(
    DateTime day,
    AvailabilityProvider provider,
    bool isToday, {
    bool isSelected = false,
  }) {
    final isPast = day.isBefore(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    final entry = provider.getAvailabilityForDate(day);

    Color? backgroundColor;
    Color textColor = Colors.black;

    if (entry != null) {
      switch (entry.status) {
        case AvailabilityStatus.booked:
          backgroundColor = const Color(0xFFFEF2F2);
          textColor = const Color(0xFFEF2F55);
          break;
        case AvailabilityStatus.unavailable:
          backgroundColor = const Color(0xFFF3F4F6);
          textColor = Colors.grey[700]!;
          break;
        case AvailabilityStatus.available:
          backgroundColor = Colors.white;
          break;
      }
    }

    if (isSelected) {
      return Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFEF2F55), width: 2),
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Opacity(
          opacity: isPast ? 0.4 : 1.0,
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: textColor,
              fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[300]!),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showEditSheet(
    BuildContext context,
    DateTime selectedDate,
    AvailabilityProvider provider,
  ) {
    final isPast = selectedDate.isBefore(
      DateTime.now().subtract(const Duration(days: 1)),
    );

    if (isPast) {
      return;
    }

    final existingEntry = provider.getAvailabilityForDate(selectedDate);
    final noteController = TextEditingController(
      text: existingEntry?.note ?? '',
    );
    AvailabilityStatus? selectedStatus = existingEntry?.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(selectedDate),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Update Availability',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildStatusChip(
                        label: 'Booked',
                        color: const Color(0xFFEF2F55),
                        isSelected: selectedStatus == AvailabilityStatus.booked,
                        onTap: () {
                          setSheetState(() {
                            selectedStatus = AvailabilityStatus.booked;
                          });
                        },
                      ),
                      _buildStatusChip(
                        label: 'Unavailable',
                        color: Colors.grey,
                        isSelected:
                            selectedStatus == AvailabilityStatus.unavailable,
                        onTap: () {
                          setSheetState(() {
                            selectedStatus = AvailabilityStatus.unavailable;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      labelText: 'Note (Optional)',
                      hintText: 'e.g., Wedding at Grand Hotel',
                      labelStyle: const TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFFEF2F55),
                          width: 2,
                        ),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      if (existingEntry != null)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await provider.removeAvailability(selectedDate);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(
                                color: Color(0xFFEF2F55),
                                width: 1.5,
                              ),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Clear',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFEF2F55),
                              ),
                            ),
                          ),
                        ),
                      if (existingEntry != null) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedStatus == null
                              ? null
                              : () async {
                                  Navigator.pop(context);
                                  await provider.updateAvailability(
                                    date: selectedDate,
                                    status: selectedStatus!,
                                    note: noteController.text.trim().isEmpty
                                        ? null
                                        : noteController.text.trim(),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF2F55),
                            disabledBackgroundColor: Colors.grey[300],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusChip({
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
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

    final day = date.day;
    final suffix = _getDaySuffix(day);
    final month = months[date.month - 1];
    final year = date.year;

    return '$day$suffix $month $year';
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
