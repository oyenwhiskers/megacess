import 'package:flutter/material.dart';

class CheckerView extends StatelessWidget {
  final String checkerName;
  final int daysBeforePayroll;
  final int pendingApproval;
  final int absent;
  final int completed;

  const CheckerView({
    Key? key,
    this.checkerName = 'checker_name',
    this.daysBeforePayroll = 20,
    this.pendingApproval = 3,
    this.absent = 3,
    this.completed = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7ED957), Color(0xFFB2F7EF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hello, $checkerName',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.grey, size: 28),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Days before payroll', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(width: 6),
                              const Icon(Icons.payments, size: 18, color: Colors.purple),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('$daysBeforePayroll', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.pause_circle_filled, color: Colors.amber),
                          const SizedBox(width: 6),
                          const Text('Pending Approval', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(width: 6),
                          Text('$pendingApproval', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.remove_circle, color: Colors.red),
                                    const SizedBox(width: 4),
                                    const Text('Absent', style: TextStyle(fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text('$absent', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.green),
                                    const SizedBox(width: 4),
                                    const Text('Completed', style: TextStyle(fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text('$completed', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Modules:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    color: Colors.white,
                    child: ListTile(
                      leading: const Icon(Icons.verified_user, color: Colors.teal, size: 26),
                      title: const Text('Check Attendance', style: TextStyle(fontSize: 15)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    color: Colors.white,
                    child: ListTile(
                      leading: const Icon(Icons.assignment, color: Colors.teal, size: 26),
                      title: const Text('Audit Tasks', style: TextStyle(fontSize: 15)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    color: Colors.white,
                    child: ListTile(
                      leading: const Icon(Icons.bar_chart, color: Colors.teal, size: 26),
                      title: const Text('Analytics', style: TextStyle(fontSize: 15)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
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
