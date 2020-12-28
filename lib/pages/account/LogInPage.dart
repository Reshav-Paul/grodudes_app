import 'package:flutter/material.dart';
import 'package:grodudes/helper/Constants.dart';
import 'package:grodudes/state/user_state.dart';
import 'package:provider/provider.dart';

final InputDecoration defaultTextFieldDecoration = InputDecoration(
  labelStyle: TextStyle(color: Colors.grey[600]),
  alignLabelWithHint: true,
  focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
    color: GrodudesPrimaryColor.primaryColor[600],
    width: 2,
  )),
  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
  contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
);

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController;
  TextEditingController _passwordController;
  TextEditingController _emailController;
  String action;

  @override
  void initState() {
    this._usernameController = new TextEditingController();
    this._passwordController = new TextEditingController();
    this._emailController = new TextEditingController();
    this.action = 'login';
    super.initState();
  }

  @override
  void dispose() {
    this._usernameController.dispose();
    this._passwordController.dispose();
    this._emailController.dispose();
    super.dispose();
  }

  Widget getFormInputField(
      String title, TextEditingController inputController) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.8,
      child: TextFormField(
        decoration: defaultTextFieldDecoration.copyWith(
          labelText: title,
          hintText: title,
          prefixIcon: title == 'Username'
              ? Icon(Icons.account_circle, color: Colors.green[700])
              : title == 'Email'
                  ? Icon(Icons.email, color: Colors.green[700])
                  : Icon(Icons.security, color: Colors.green[700]),
        ),
        controller: inputController,
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  _handleFormSubmit() {
    bool valuesAvailable = true;
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    if (this._usernameController.text.length == 0 ||
        this._passwordController.text.length == 0) {
      valuesAvailable = false;
    }
    if (this.action == 'register' && this._emailController.text.length == 0) {
      valuesAvailable = false;
    }
    if (valuesAvailable == false) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all the feilds'),
        ),
      );
      return;
    }
    if (this.action == 'login') {
      Provider.of<UserManager>(context, listen: false)
          .logInToWordpress(
              this._usernameController.text, this._passwordController.text)
          .catchError((err) {
        print(err);
      });
    } else if (this.action == 'register') {
      Provider.of<UserManager>(context, listen: false)
          .registerNewUser(
        this._usernameController.text,
        this._emailController.text,
        this._passwordController.text,
      )
          .catchError((err) {
        print(err);
      });
    }
  }

  Widget _getErrorPrompt() {
    Map<String, dynamic> wpUserInfo =
        Provider.of<UserManager>(context, listen: false).wpUserInfo;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        color: Color(0x39ff0000),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[300], width: 2),
      ),
      child: Text(wpUserInfo['errMsg'] ?? 'Login Failed. Please try again.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      children: <Widget>[
        SizedBox(height: MediaQuery.of(context).size.height * 0.1),
        Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              this.action == 'login'
                  ? Icon(Icons.person, size: 60, color: Colors.black54)
                  : Icon(Icons.person_add, size: 60, color: Colors.black54),
              Text(
                this.action == 'login'
                    ? 'Login to your Account'
                    : 'Create a new Account',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 40),
              getFormInputField('Username', this._usernameController),
              SizedBox(height: 14),
              _PasswordFromInputRow(this._passwordController),
              this.action == 'login'
                  ? SizedBox(height: 0)
                  : SizedBox(height: 14),
              this.action == 'login'
                  ? SizedBox(height: 0)
                  : getFormInputField('Email', this._emailController),
              SizedBox(height: 12),
              RaisedButton(
                onPressed: _handleFormSubmit,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Text(
                  this.action == 'login' ? 'Login' : 'Register',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    this.action == 'login' ? 'New User?' : 'Existing User?',
                    style: TextStyle(fontSize: 16),
                  ),
                  MaterialButton(
                    child: Text(
                      this.action == 'login' ? 'Register' : 'Login',
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () => setState(() {
                      this.action =
                          this.action == 'login' ? 'register' : 'login';
                    }),
                  )
                ],
              ),
              SizedBox(height: 8),
              Provider.of<UserManager>(context).getLogInStatus() ==
                      logInStates.logInFailed
                  ? _getErrorPrompt()
                  : SizedBox(height: 0),
              SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class _PasswordFromInputRow extends StatefulWidget {
  final TextEditingController inputController;
  _PasswordFromInputRow(this.inputController);
  @override
  __PasswordFromInputRowState createState() => __PasswordFromInputRowState();
}

class __PasswordFromInputRowState extends State<_PasswordFromInputRow> {
  final String title = 'Password';
  bool isObscured;
  @override
  void initState() {
    this.isObscured = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.8,
      child: TextFormField(
        obscureText: this.isObscured,
        autocorrect: false,
        decoration: defaultTextFieldDecoration.copyWith(
          labelText: title,
          hintText: title,
          prefixIcon: Icon(Icons.security, color: Colors.green[700]),
          suffixIcon: GestureDetector(
            child: Icon(Icons.remove_red_eye,
                color: GrodudesPrimaryColor.primaryColor[600]),
            onTap: () => setState(() => this.isObscured = !this.isObscured),
          ),
        ),
        controller: widget.inputController,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
