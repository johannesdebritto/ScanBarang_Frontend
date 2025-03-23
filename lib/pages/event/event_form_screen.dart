import 'package:flutter/material.dart';
import 'event_form_logic.dart';

class EventFormScreen extends StatefulWidget {
  final EventFormLogic eventFormLogic; // ✅ Tambahkan parameter

  const EventFormScreen({Key? key, required this.eventFormLogic})
      : super(key: key);

  @override
  State<EventFormScreen> createState() => EventFormScreenState();
}

class EventFormScreenState extends State<EventFormScreen> {
  // ✅ Gunakan eventFormLogic yang dikirim dari luar, bukan deklarasi baru

  EventFormLogic getLogic() {
    return widget.eventFormLogic; // ✅ Ambil dari widget agar tetap sinkron
  }

  void simpanEvent(BuildContext context) {
    widget.eventFormLogic.simpanEvent(context); // ✅ Panggil dari eventFormLogic
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0052AB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.event_note, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'FORM EVENT',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              buildTextField(
                  controller: widget.eventFormLogic.namaEventController,
                  label: 'Nama Event'),
              buildDateField(
                  controller: widget.eventFormLogic.tanggalController,
                  label: 'TANGGAL EVENT'),
              buildLocationFields(
                cityController: widget.eventFormLogic.cityController,
                provinceController: widget.eventFormLogic.provinceController,
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget buildTextField(
      {required TextEditingController controller, required String label}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: textStyle()),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            decoration: inputDecoration(),
          ),
        ],
      ),
    );
  }

  Widget buildDateField(
      {required TextEditingController controller, required String label}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: textStyle()),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                setState(() {
                  controller.text =
                      "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                });
              }
            },
            decoration:
                inputDecoration(suffixIcon: const Icon(Icons.calendar_today)),
          ),
        ],
      ),
    );
  }

  Widget buildLocationFields({
    required TextEditingController cityController,
    required TextEditingController provinceController,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LOKASI EVENT', style: textStyle()),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: buildTextField(
                      controller: cityController, label: 'Kota/Kabupaten')),
              const SizedBox(width: 16),
              Expanded(
                  child: buildTextField(
                      controller: provinceController, label: 'Provinsi')),
            ],
          ),
        ],
      ),
    );
  }

  TextStyle textStyle() {
    return const TextStyle(
        color: Colors.black, fontWeight: FontWeight.w900, fontSize: 15);
  }

  InputDecoration inputDecoration({Widget? suffixIcon}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      suffixIcon: suffixIcon,
    );
  }
}
