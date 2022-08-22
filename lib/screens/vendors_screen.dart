import 'package:flutter/material.dart';
import 'package:shop_app_admin/widgets/vendors_list.dart';

class VendorScreen extends StatefulWidget {
  static const String id = 'vendor-screen';
  const VendorScreen({Key? key}) : super(key: key);

  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  Widget _rowHeader({int? flex, String? text}) {
    return Expanded(
      flex: flex!,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade700),
          color: Colors.grey.shade400,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(text!),
        ),
      ),
    );
  }

  bool? selectedButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Registered Vendors',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 22,
                ),
              ),
              Container(
                child: Row(children: [
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            selectedButton == true
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade500)),
                    onPressed: () {
                      setState(() {
                        selectedButton = true;
                      });
                    },
                    child: const Text("Accepted"),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            selectedButton == false
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade500)),
                    onPressed: () {
                      setState(() {
                        selectedButton = false;
                      });
                    },
                    child: const Text("Not Approved Yet"),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            selectedButton == null
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade500)),
                    onPressed: () {
                      setState(() {
                        selectedButton = null;
                      });
                    },
                    child: const Text("All"),
                  ),
                ]),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              _rowHeader(flex: 1, text: 'Logo'),
              _rowHeader(flex: 3, text: 'Business Name'),
              _rowHeader(flex: 2, text: 'City'),
              _rowHeader(flex: 2, text: 'State'),
              _rowHeader(flex: 1, text: 'Action'),
              _rowHeader(flex: 1, text: 'View More'),
            ],
          ),
          VendorsList(
            approveStatus: selectedButton,
          ),
        ],
      ),
    );
  }
}
