import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/widgets/main_layout_rt.dart';

class RiwayatPageRT extends StatefulWidget {
  const RiwayatPageRT({super.key});

  @override
  _RiwayatPageRTState createState() => _RiwayatPageRTState();
}

class _RiwayatPageRTState extends State<RiwayatPageRT> {
  DateTime _selectedDate = DateTime.now(); // Default to current date

  // Dummy data for transactions
  final List<Map<String, String>> transactions = [
    {
      'name': 'Raymond',
      'payment': 'Uang Sampah',
      'amount': 'Rp10.000',
      'date': '31 Agustus 2025',
    },
    {
      'name': 'Jefri',
      'payment': 'Uang Keamanan',
      'amount': 'Rp15.000',
      'date': '31 Agustus 2025',
    },
    {
      'name': 'Siti',
      'payment': 'Uang Kebersihan',
      'amount': 'Rp15.000',
      'date': '31 Agustus 2025',
    },
    {
      'name': 'Budi',
      'payment': 'Uang Sampah',
      'amount': 'Rp10.000',
      'date': '30 Juli 2025',
    },
    {
      'name': 'Ani',
      'payment': 'Uang Keamanan',
      'amount': 'Rp15.000',
      'date': '30 Juli 2025',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return MainLayoutRT(
      selectedIndex: 1,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/logoputih.png', height: 50),
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/images/avatar.jpg'),
                  backgroundColor: Colors.white,
                ),
              ],
            ),
          ),

          // Body Content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Riwayat Administrasi",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date picker section
                    _buildDatePicker(),

                    const SizedBox(height: 20),

                    // Date Sections (Transaction History)
                    _buildDateSection("31 Agustus 2025", [
                      _buildTransactionItem(
                        "Raymond",
                        "Uang Sampah",
                        "Rp10.000",
                      ),
                      _buildTransactionItem(
                        "Jefri",
                        "Uang Keamanan",
                        "Rp15.000",
                      ),
                      _buildTransactionItem(
                        "Siti",
                        "Uang Kebersihan",
                        "Rp15.000",
                      ),
                    ]),

                    const SizedBox(height: 20),

                    _buildDateSection("30 Juli 2025", [
                      _buildTransactionItem("Budi", "Uang Sampah", "Rp10.000"),
                      _buildTransactionItem("Ani", "Uang Keamanan", "Rp15.000"),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Tanggal: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: _selectDate,
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  Widget _buildDateSection(String date, List<Widget> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1, color: Colors.grey),
        const SizedBox(height: 8),
        Column(children: transactions),
      ],
    );
  }

  Widget _buildTransactionItem(String name, String title, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8B0),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Center(
              child: Text(
                "Rp",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCC8800),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "$name membayar $title",
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
