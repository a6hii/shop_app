import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shop_app_admin/firebase_service.dart';
import 'package:shop_app_admin/widgets/main_categories_list_widget.dart';

class MainCategoryScreen extends StatefulWidget {
  static const String id = 'main-category';
  const MainCategoryScreen({Key? key}) : super(key: key);

  @override
  State<MainCategoryScreen> createState() => _MainCategoryScreenState();
}

class _MainCategoryScreenState extends State<MainCategoryScreen> {
  final FirebaseService _service = FirebaseService();
  final TextEditingController _mainCat = TextEditingController();
  QuerySnapshot? snapshot;
  final _formKey = GlobalKey<FormState>();
  Object? _selectedValue;
  bool _isCategorySelected = false;

  Widget _dropDownButton() {
    return DropdownButton(
        value: _selectedValue,
        hint: const Text('Select category'),
        items: snapshot!.docs.map((e) {
          return DropdownMenuItem<String>(
            value: e['catName'],
            child: Text(
              e['catName'],
            ),
          );
        }).toList(),
        onChanged: (selectedCat) {
          setState(() {
            _selectedValue = selectedCat;
            _isCategorySelected = false;
          });
        });
  }

  clear() {
    setState(() {
      _selectedValue = null;
      _mainCat.clear();
    });
  }

  @override
  void initState() {
    getCatList();
    super.initState();
  }

  getCatList() {
    return _service.categories.get().then((QuerySnapshot querySnapshot) {
      setState(() {
        snapshot = querySnapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(10),
              child: const Text(
                'Main Category',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 36,
                ),
              ),
            ),
            const Divider(
              color: Colors.grey,
            ),
            snapshot == null ? const Text('Loading...') : _dropDownButton(),
            const SizedBox(
              height: 8,
            ),
            if (_isCategorySelected == true)
              const Text(
                'No Category Selected',
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(
              width: 200,
              child: TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter Main Category Name';
                  }
                },
                controller: _mainCat,
                decoration: const InputDecoration(
                  label: Text('Enter catgory name:'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                TextButton(
                  onPressed: clear,
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    side: MaterialStateProperty.all(
                      BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedValue == null) {
                      setState(() {
                        _isCategorySelected = true;
                      });
                      return;
                    }
                    if (_formKey.currentState!.validate()) {
                      EasyLoading.show();
                      _service.saveCategory(
                        data: {
                          'category': _selectedValue, //drop down value
                          'mainCategory': _mainCat.text, ////textFormField value
                          'approved': true,
                        },
                        reference: _service.mainCat,
                        docName: _mainCat.text,
                      ).then((value) {
                        clear();
                        EasyLoading.dismiss();
                      });
                    }
                  },
                  child: const Text(
                    'Save',
                  ),
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(5.0),
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).primaryColor),
                    side: MaterialStateProperty.all(
                      BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(10),
              child: const Text(
                'Main Categories List',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            const Divider(
              color: Colors.grey,
            ),
            const MainCategoryListWidget(),
          ],
        ),
      ),
    );
  }
}
