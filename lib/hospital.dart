import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Hospital {
  final String name;
  final String address;
  final String region;
  final String phone;

  Hospital({
    required this.name,
    required this.address,
    required this.region,
    required this.phone,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      region: json['region'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

class HospitalScreen extends StatefulWidget {
  @override
  _HospitalScreenState createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen> {
  late Future<List<Hospital>> futureHospitals;

  @override
  void initState() {
    super.initState();
    futureHospitals = fetchHospitals();
  }

  Future<List<Hospital>> fetchHospitals() async {
    final response = await http.get(Uri.parse('https://dekontaminasi.com/api/id/covid19/hospitals'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print(data);
      return data.map((e) => Hospital.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load hospitals');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hospital List'),
      ),
      body: FutureBuilder<List<Hospital>>(
        future: futureHospitals,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List<Hospital> hospitals = snapshot.data!;
            return ListView.builder(
              itemCount: hospitals.length,
              itemBuilder: (context, index) {
                final Hospital hospital = hospitals[index];
                return ListTile(
                  title: Text(hospital.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Address: ${hospital.address}'),
                      Text('Region: ${hospital.region}'),
                      Text('Phone: ${hospital.phone}'),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}