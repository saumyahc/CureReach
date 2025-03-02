import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'AppointmentDetailsPage.dart';

class AppointmentBookingPage extends StatefulWidget {
  final String doctorName;

  const AppointmentBookingPage({Key? key, required this.doctorName})
    : super(key: key);

  @override
  _AppointmentBookingPageState createState() => _AppointmentBookingPageState();
}

class _AppointmentBookingPageState extends State<AppointmentBookingPage> {
  final TextEditingController _medicationsController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _surgeriesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String _generatePaymentURL() {
    return "upi://pay?pa=YOUR_UPI_ID&pn=Doctor&mc=0000&tid=123456789&tr=987654321&tn=Appointment%20Fee&am=50&cu=INR";
  }

  Future<void> _confirmPayment() async {
    String meetingID = "meeting_${DateTime.now().millisecondsSinceEpoch}";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AppointmentDetailsPage(
              doctorName: widget.doctorName,
              appointmentDate: _selectedDate ?? DateTime.now(),
              appointmentTime: _selectedTime ?? TimeOfDay.now(),
              meetingID: meetingID,
            ),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book Appointment"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Info
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue[100],
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Dr. ${widget.doctorName}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Specialist",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Form Fields
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _medicationsController,
                      decoration: const InputDecoration(
                        labelText: "Current Medications",
                        prefixIcon: Icon(Icons.medication),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _allergiesController,
                      decoration: const InputDecoration(
                        labelText: "Allergies",
                        prefixIcon: Icon(Icons.warning),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _surgeriesController,
                      decoration: const InputDecoration(
                        labelText: "Recent Surgeries or Hospitalizations",
                        prefixIcon: Icon(Icons.local_hospital),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Date & Time Pickers
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        _selectedDate == null
                            ? "Select Date"
                            : "Date: ${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}",
                      ),
                      leading: const Icon(
                        Icons.calendar_today,
                        color: Colors.blueAccent,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_calendar),
                        onPressed: _selectDate,
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      title: Text(
                        _selectedTime == null
                            ? "Select Time"
                            : "Time: ${_selectedTime!.format(context)}",
                      ),
                      leading: const Icon(
                        Icons.access_time,
                        color: Colors.blueAccent,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.schedule),
                        onPressed: _selectTime,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Payment Section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      "Scan QR Code to Pay",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Image.network(
                        "https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${Uri.encodeComponent(_generatePaymentURL())}",
                        height: 150,
                        width: 150,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Appointment Fee: ₹50",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Confirm Payment Button
            Center(
              child: ElevatedButton(
                onPressed: _confirmPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Confirm Payment",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
