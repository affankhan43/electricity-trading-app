class ValidationMixins {
  
  String validateEmail (String value){
    if(!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)){
      return 'Invalid Email';
    }
    return null;
  }

  String validatePassword (String value){
    if(value.length < 4){
      return 'Password Length Must be upto 4 charachters';
    }
    return null;
  }

  String validateRate (String value){
    if(value == null){
      return 'Please fill the desired Rate';
    }else if(int.parse(value) == null){
      print(value);
      return 'Rate Value Must Be Numeric';
    }
    return null;
  }
}