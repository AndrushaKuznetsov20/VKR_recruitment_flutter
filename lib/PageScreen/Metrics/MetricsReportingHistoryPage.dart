import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recruitment/PageScreen/Metrics/MetricsPage.dart';
import '../../Models/MetricsReportingHistory.dart';
import '../LK/LK.dart';
import 'package:intl/intl.dart';

class MetricsReportingHistoryPage extends StatefulWidget {
  final String token;
  MetricsReportingHistoryPage({required this.token});

  @override
  MetricsReportingHistoryPageState createState() => MetricsReportingHistoryPageState();
}

class MetricsReportingHistoryPageState extends State<MetricsReportingHistoryPage> {
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  List<MetricsReportingHistory> dataListMetricsReportingHistory = [];

  Future<void> getAllMetricsReportingHistory() async {

    final response = await http.get(
      Uri.parse(
          'http://172.20.10.3:8092/metricsReportingHistory/getAllMetricsReportingHistory'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as List<dynamic>;

      List<MetricsReportingHistory> metricsReportingHistoryList = [];
      for (var metricsReportingHistoryListJson in jsonData) {
        metricsReportingHistoryList.add(MetricsReportingHistory.fromJson(metricsReportingHistoryListJson));
      }

      setState(() {
        dataListMetricsReportingHistory = metricsReportingHistoryList;
      });
    }
  }

  Future<void> deleteMetricsReportingHistory(BuildContext context, int metricsReportingId) async {
    final response = await http.delete(
      Uri.parse(
          'http://172.20.10.3:8092/metricsReportingHistory/delete/$metricsReportingId'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
    }
    getAllMetricsReportingHistory();
    Navigator.of(context).pop();
  }

  void showDeleteConfirmationDialog(BuildContext context, int metricsReportingId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Удалить отчёт?'),
          content: Text('Вы действительно хотите удалить этот отчёт?'),
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.not_interested, color: Colors.red),
              label: Text('Нет'),
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all<Color>(Colors.grey.shade900),
                foregroundColor:
                MaterialStateProperty.all<Color>(Colors.white),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                deleteMetricsReportingHistory(context, metricsReportingId);
              },
              icon: Icon(Icons.check, color: Colors.green),
              label: Text('Да'),
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all<Color>(Colors.grey.shade900),
                foregroundColor:
                MaterialStateProperty.all<Color>(Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getAllMetricsReportingHistory();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'История отчётов',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey.shade900,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MetricsPage(token: widget.token)));
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LK(token: widget.token)),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: dataListMetricsReportingHistory.length,
              itemBuilder: (context, index) {
                final data = dataListMetricsReportingHistory[index];
                return Card(
                    margin: EdgeInsets.all(8),
                    elevation: 4,
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          Icon(Icons.menu, color: Colors.grey.shade900),
                          SizedBox(width: 8),
                          Text('${dateFormat.format(data.startDate)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue)),
                          Text('-',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          Text('${dateFormat.format(data.endDate)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red)),
                        ],
                      ),
                      iconColor: Colors.grey.shade900,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Количество вакансий:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(data.countVacancies.toString()),
                              Divider(),
                              Text('Количество откликов:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(data.countResponses.toString()),
                              Divider(),
                              Text('Количество релевантных откликов:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(data.countRelevantResponse.toString()),
                              Divider(),
                              Text('Количество самоотказов:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(data.countSelfDanial.toString()),
                              Divider(),
                              Text('Количество отказов работодателя:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(data.countRefusalEmployer.toString()),
                              Divider(),
                              Text('Количество приглашений:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(data.countInvitation.toString()),
                              SizedBox(height: 4),
                              IconButton(
                                icon: Icon(Icons.delete_forever, color: Colors.black),
                                onPressed: () {
                                  showDeleteConfirmationDialog(context, data.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
