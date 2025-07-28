// lib/screens/meal_plan_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

import '../models/delivery.dart';
import '../models/meal.dart';
import '../services/api_service.dart' as api;

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});
  @override
  MealPlanScreenState createState() => MealPlanScreenState();
}

class MealPlanScreenState extends State<MealPlanScreen> {
  List<Delivery> deliveries = [];
  DateTime selectedDate = DateTime.now();
  final List<DateTime> nextFiveDays = List.generate(
    5,
    (i) => DateTime.now().add(Duration(days: i)),
  );

  // Per‐delivery UI state
  final Map<int, bool> isPickup = {};
  final Map<int, String?> selectedAddress = {};
  final Map<int, String?> selectedTime = {};

  final List<String> _timeOptions = [
    '08:00 AM','09:00 AM','10:00 AM','11:00 AM','12:00 PM',
    '01:00 PM','02:00 PM','03:00 PM','04:00 PM','05:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _loadDeliveriesFor(selectedDate);
  }

  Future<void> _loadDeliveriesFor(DateTime date) async {
    
    final dayString = DateFormat('yyyy-MM-dd').format(date);

    try {
      // 1) Fetch deliveries by day
      final fetchedDeliveries = 
          await api.ApiService.fetchDeliveriesByDay(dayString);
      
      for (var d in fetchedDeliveries) {
        
        final meals = await api.ApiService.fetchMealsByDeliveryId(d.id);
        

        // DEBUG: print how many meals came back (and maybe names)
        // debugPrint('     • got ${meals.length} meals: '
        //   '${meals.map((m) => m.title).join(", ")}');

        d.meals = meals;  // make sure your model's `meals` is mutable (not final)
      }

      // 3) Initialize per‐delivery UI maps
      for (int i = 0; i < fetchedDeliveries.length; i++) {
        isPickup[i] = false;
        selectedAddress[i] = fetchedDeliveries[i].address;
        selectedTime[i] = fetchedDeliveries[i].time;
      }

      // 4) Update state
      setState(() {
        deliveries = fetchedDeliveries;
      });
    } catch (err) {
      debugPrint('!!! error in _loadDeliveriesFor: $err');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(content: Text('Error fetching for $dayString')),
        );
      });
    }
  }

  void _pickDate() {
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: DateTime.now().add(Duration(days: 30)),
      onConfirm: (picked) {
        setState(() => selectedDate = picked);
        _loadDeliveriesFor(picked);
      },
      currentTime: selectedDate,
      locale: LocaleType.en,
    );
  }

  void _showRescheduleDialog(int idx) {
  DateTime tempDate = selectedDate;
  String? tempTime = selectedTime[idx];

  // Build the list of time options, ensuring the current one is included
  final times = [..._timeOptions];
  if (tempTime != null && !times.contains(tempTime)) {
    times.insert(0, tempTime);
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetCtx) => FractionallySizedBox(
      heightFactor: 0.5,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
          top: 16, left: 16, right: 16,
        ),
        child: StatefulBuilder(builder: (ctx, setModalState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Reschedule Delivery',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),

              // Date pills
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: nextFiveDays.length,
                  itemBuilder: (_, i) {
                    final d = nextFiveDays[i];
                    final key = DateFormat('yyyy-MM-dd').format(d);
                    final selKey = DateFormat('yyyy-MM-dd').format(tempDate);
                    final isSel = key == selKey;
                    return GestureDetector(
                      onTap: () => setModalState(() => tempDate = d),
                      child: Container(
                        width: 56,
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: isSel ? Colors.blue : Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          DateFormat('E\ndd').format(d).toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: isSel ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 16),

              // Time dropdown
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Time',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                value: tempTime,
                items: times
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setModalState(() => tempTime = v),
              ),

              SizedBox(height: 16),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('CANCEL'),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      // 1) Close the sheet
                      Navigator.pop(ctx);

                      // 2) If rescheduling for today, bump past times
                      final now = DateTime.now();
                      if (tempDate.year == now.year &&
                          tempDate.month == now.month &&
                          tempDate.day == now.day) {
                        for (var slot in times) {
                          // Parse "hh:mm AM/PM"
                          final parts = slot.split(RegExp(r'[: ]'));
                          var hour = int.parse(parts[0]);
                          final minute = int.parse(parts[1]);
                          final ampm = parts[2];
                          if (ampm == 'PM' && hour < 12) hour += 12;
                          if (ampm == 'AM' && hour == 12) hour = 0;
                          final slotDt = DateTime(
                              tempDate.year, tempDate.month, tempDate.day, hour, minute);
                          if (slotDt.isAfter(now)) {
                            tempTime = slot;
                            break;
                          }
                        }
                      }

                      // 3) Fire‑and‑forget the update call properly
                      api.ApiService
                          .updateDeliveryDateTime(
                            deliveryId: deliveries[idx].id,
                            day: DateFormat('yyyy-MM-dd').format(tempDate),
                            time: tempTime!,
                          )
                          .then((_) {
                            // optional: log success
                          })
                          .catchError((err) {
                            // optional: log failure
                          });

                      // 4) Refresh the list for the newly chosen date
                      _loadDeliveriesFor(tempDate);
                    },
                    child: Text('SAVE'),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    ),
  );
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscriptions'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Date pills row ---
          SizedBox(
            height: 80,
            child: GestureDetector(
              onTapDown: (_) => print("📦 PillRow tapped!"),
              child:ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: nextFiveDays.length,
              itemBuilder: (ctx, idx) {
                final date = nextFiveDays[idx];
                final key = DateFormat('yyyy-MM-dd').format(date);
                final selKey =
                    DateFormat('yyyy-MM-dd').format(selectedDate);
                final isSel = key == selKey;
                final label =
                    DateFormat('E\ndd').format(date).toUpperCase();

                return GestureDetector(
                  onTap: () {
                    setState(() => selectedDate = date);
                    _loadDeliveriesFor(date);
                  },
                  child: Container(
                    width: 56,
                    margin: EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSel ? Colors.black : Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSel ? Colors.white : Colors.black,
                        fontWeight:
                            isSel ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          ),

          // --- Delivery blocks ---
          Expanded(
            child: deliveries.isEmpty
                ? Center(child: Text('No deliveries for this day'))
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: deliveries.length,
                    itemBuilder: (ctx, idx) {
                      final delivery = deliveries[idx];
                      return _buildDeliveryBlock(idx, delivery);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryBlock(int idx, Delivery d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: “Delivery #” + toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Delivery ${idx + 1}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Text('Change to Pickup'),
                Switch(
                  value: isPickup[idx] ?? false,
                  onChanged: (v) => setState(() => isPickup[idx] = v),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 8),

        
        // Address & Time dropdowns + Reschedule button, allow horizontal scrolling
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              // 1) Address dropdown fixed width
              SizedBox(
                width: 100, // adjust this as needed
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  value: selectedAddress[idx],
                  items: [
                    DropdownMenuItem(value: d.address, child: Text(d.address)),
                  ],
                  onChanged: (v) => setState(() => selectedAddress[idx] = v),
                ),
              ),

              SizedBox(width: 12),

              // 2) Time dropdown fixed width
              SizedBox(
                width: 100,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Time',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  value: selectedTime[idx],
                  items: [
                    DropdownMenuItem(value: d.time, child: Text(d.time)),
                  ],
                  onChanged: (v) => setState(() => selectedTime[idx] = v),
                ),
              ),

                SizedBox(width: 12),

                // 3) Reschedule button
                ElevatedButton(
                  onPressed: 
                  () => _showRescheduleDialog(idx),
                  child: Text('Reschedule'),
                ),
              ],
            ),
          ),



        SizedBox(height: 16),

        // Meal cards (without images)
        ...d.meals.map((m) => _buildMealCard(m)),

        Divider(height: 32),
      ],
    );
  }

  Widget _buildMealCard(Meal m) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal title & macros
            Text(
              m.title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Protein ${m.protein} · Fat ${m.fat} · Carbs ${m.carbs}g · ${m.calories} cal',
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 4),
            Text('Delivery Type: ${m.deliveryType}'),
            SizedBox(height: 12),

            // Skip / Swap / Move buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.fast_forward),
                  label: Text('Skip'),
                  onPressed: () {/* skip logic */},
                ),
                TextButton.icon(
                  icon: Icon(Icons.swap_horiz),
                  label: Text('Swap'),
                  onPressed: () {/* swap logic */},
                ),
                TextButton.icon(
                  icon: Icon(Icons.arrow_back),
                  label: Text('Move'),
                  onPressed: () {/* move logic */},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
