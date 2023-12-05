import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:labtest1/bmi_model.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  TextEditingController nameController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController bmiController = TextEditingController();
  int _gender = 2;
  late String comment = "";
  bool bmiVisibility = false;
  final _formKey = GlobalKey<FormState>();
  final String level1 ="Underweight. Careful during strong wind!";
  final String level2 ="That's idea! Please maintain";
  final String level3 ="Overweight! Work out please";
  final String level4 = "Whoa Obese! Dangerous mate!";
  BMI? bmi;

  @override
  void initState() {
    super.initState();
    loadBMI();
  }

  void loadBMI() async{
      BMI? loadedBMI = await BMI.load();
      if (loadedBMI != null){
        setState(() {
          bmi = loadedBMI!;
          nameController.text = bmi!.username;
          heightController.text = bmi!.height.toString();
          weightController.text = bmi!.weight.toString();
          bmiController.text = (bmi!.weight/ (bmi!.height/100 * bmi!.height/100)).toString();
          bmiVisibility = true;
          _gender = bmi!.gender;
          if (bmi!.status == 1){
            comment = level1;
          } else if (bmi!.status == 2){
            comment = level2;
          } else if (bmi!.status == 3){
            comment = level3;
          } else if (bmi!.status == 4){
            comment = level4;
          }
          displayOutput();
        });
      }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("BMI Calculator"),),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(10.0),
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                nameField(),
                heightField(),
                weightField(),
                bmiField(),
                SizedBox(height: 10.0,),
                genderText(),
                genderField(),
                buttonSave(),
                displayOutput(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget nameField(){
    return TextFormField(
      controller: nameController,
      validator: (value){
        if (value == null || value.isEmpty){
          return 'Please enter username';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText:"Your full name",
      ),
    );
  }

  Widget heightField(){
    return TextFormField(
      keyboardType: TextInputType.number,
      controller: heightController,
      validator: (value){
        if (value == null || value.isEmpty){
          return 'Please enter height';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText:"Height in cm; 170",
      ),
    );
  }

  Widget weightField(){
    return TextFormField(
      keyboardType: TextInputType.number,
      controller: weightController,
      validator: (value){
        if (value == null || value.isEmpty){
          return 'Please enter weight';
        }
        return null;
      },
      decoration: const InputDecoration(
        hintText:"Weight in KG",
      ),
    );
  }

  Widget genderText(){
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("BMI value"),
        ],
      ),
    );
  }

  Widget genderField() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RadioListTile(
                  title: Text('Male', style: TextStyle(fontSize: 14),),
                  value: 0,
                  groupValue: _gender,
                  onChanged: (value) {
                    setState(() {
                      _gender = value!;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile(
                  title: Text('Female', style: TextStyle(fontSize: 14),),
                  value: 1,
                  groupValue: _gender,
                  onChanged: (value) {
                    setState(() {
                      _gender = value!;
                    });
                    },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget bmiField(){
    return Visibility(
      visible: bmiVisibility,
      child: TextFormField(
        controller: bmiController,
        readOnly: true,
      ),
    );
  }

  Widget buttonSave(){
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: ElevatedButton(
        onPressed: () async{
          double weight = 0, height = 0;
          int bmistatus = 0;
          if(_formKey.currentState!.validate()) {
             weight = double.parse(weightController.text.toString().trim());
             height = double.parse(heightController.text.toString().trim());
            double bmi = weight / (height/100 * height/100);
            if (_gender == 1){
              if (bmi < 16){
                comment = level1;
                bmistatus = 1;
              } else if (bmi >= 16 && bmi < 22){
                comment = level2;
                bmistatus = 2;
              } else if (bmi >= 22 && bmi < 27){
                comment = level3;
                bmistatus = 3;
              } else if (bmi >= 27){
                comment = level4;
                bmistatus = 4;
              }
            }
            else if (_gender  == 0 ){
              if (bmi < 18.5){
                comment = level1;
                bmistatus = 1;
              }
              else if (bmi >=18.5 && bmi <=24.9){
                comment = level2;
                bmistatus = 2;
              } else if (bmi >=25.0 && bmi <=29.9){
                comment = level3;
                bmistatus = 3;
              } else if (bmi >= 30.0){
                comment = level4;
                bmistatus = 4;
              }
            }

            bmiController.text = bmi.toString();
            bmiVisibility = true;
          }
          setState(() {
            displayOutput();
          });

          BMI bmi = BMI(
            username: nameController.text.trim().toString(),
            weight: double.parse(weight.toString()),
            height: double.parse(height.toString()),
            gender: _gender,
            status: bmistatus,
          );

          if (await bmi.save()){
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('BMI has been saved'))
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fail to save'))
            );
          }
        },
        child: Text("Calculate BMI and save"),
      ),
    );
  }

  Widget displayOutput(){
    return Padding(
      padding: const EdgeInsets.only(top: 25.0),
      child: Text(comment),
    );
  }
}

