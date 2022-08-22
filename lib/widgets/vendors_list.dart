import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shop_app_admin/firebase_service.dart';
import 'package:shop_app_admin/models/vendor_model.dart';

class VendorsList extends StatelessWidget {
  final bool? approveStatus;
  const VendorsList({this.approveStatus, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseService _service = FirebaseService();

    Widget _vendorData({int? flex, String? text, Widget? widget}) {
      return Expanded(
        flex: flex!,
        child: Container(
          height: 56,
          decoration:
              BoxDecoration(border: Border.all(color: Colors.grey.shade400)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: widget ?? Text(text!),
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _service.vendor
          .where('approved', isEqualTo: approveStatus)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }

        if (snapshot.data!.size == 0) {
          return const Center(
            child: Text('No Vendors to show'),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data!.size,
          itemBuilder: (context, index) {
            Vendor _vendor = Vendor.fromJson(
                snapshot.data!.docs[index].data() as Map<String, dynamic>);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _vendorData(
                  flex: 1,
                  widget: Container(
                      height: 40,
                      width: 40,
                      child: Image.network(_vendor.logo!)),
                ),
                _vendorData(
                  flex: 2,
                  text: _vendor.businessName,
                ),
                _vendorData(
                  flex: 3,
                  text: _vendor.city,
                ),
                _vendorData(
                  flex: 2,
                  text: _vendor.state,
                ),
                _vendorData(
                    flex: 1,
                    widget: _vendor.approved == true
                        ? ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.red)),
                            onPressed: () {
                              EasyLoading.show();
                              _service.updateData(
                                data: {
                                  'approved': false,
                                },
                                docName: _vendor.uid,
                                reference: _service.vendor,
                              ).then((value) {
                                EasyLoading.dismiss();
                              });
                            },
                            child: const Text(
                              'Reject',
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              EasyLoading.show();
                              _service.updateData(
                                data: {
                                  'approved': true,
                                },
                                docName: _vendor.uid,
                                reference: _service.vendor,
                              ).then((value) {
                                EasyLoading.dismiss();
                              });
                            },
                            child: const Text(
                              "Accept",
                              textAlign: TextAlign.center,
                            ))),
                _vendorData(
                  flex: 1,
                  widget: ElevatedButton(
                    onPressed: () {},
                    child: const Text(
                      "View More",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
