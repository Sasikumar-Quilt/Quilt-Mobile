import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:quilt/src/api/ApiHelper.dart';
import 'package:quilt/src/auth/profile_clinic_item.dart';
import 'package:quilt/src/auth/profile_clinic_model.dart';

class ClinicSelectionWidget extends StatefulWidget {
  @override
  _ClinicSelectionWidgetState createState() => _ClinicSelectionWidgetState();
}

class _ClinicSelectionWidgetState extends State<ClinicSelectionWidget> {
  List<ProfileClinicModel> clinics = [];
  bool isLoading = true;
  ApiHelper apiHelper = ApiHelper();

  @override
  void initState() {
    super.initState();
    fetchClinics();
  }

  Future<void> fetchClinics() async {
    try {
      var response = await apiHelper.getAllClinics();
      List data = response.data as List;
      setState(() {
        clinics = data
            .map((clinicJson) => ProfileClinicModel.fromJson(clinicJson))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error accordingly
      print('Error fetching clinics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Select clinic',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Causten-Medium',
              fontSize: 24,
              fontWeight: FontWeight.w400,
              height: 1.33, // line-height equivalent (32/24)
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          isLoading
              ? const CircularProgressIndicator()
              : Expanded(
                  child: ListView.builder(
                    itemCount: clinics.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding:  EdgeInsets.only( bottom: 16),
                        child: ProfileClinicItem(
                          text: clinics[index].clinicName,
                          isSelected: false,
                          onPressed: () {
                            // Handle clinic selection logic here
                          },
                        ),
                      );
                    },
                  ),
                  
                ),
        ],
      ),
    );
  }
}
