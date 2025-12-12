import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_auth_service.dart';
import 'firebase_options.dart';

Future<void> main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget 
{
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp(
      title: 'Firebase Auth Testing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthWrapper()
    );
  }
}

class AuthWrapper extends StatelessWidget 
{
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return StreamBuilder<User?>(
      stream: AuthService().userChanges, 
      builder: (context, AsyncSnapshot snapshot)
      {
        if (snapshot.connectionState == ConnectionState.waiting) {return const Scaffold(body: CircularProgressIndicator());}
        if (snapshot.hasData) {return const HomePage();}
        return const LoginPage();
      }
    );
  }
}

class RegisterPage extends StatefulWidget 
{
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> 
{
  late final TextEditingController kontrollerEmail;
  late final TextEditingController kontrollerPassword;
  late final AuthService as;
  late bool isLoading;

  @override
  void initState() 
  {
    super.initState();
    kontrollerEmail = TextEditingController();
    kontrollerPassword = TextEditingController();
    as = AuthService();
    isLoading = false;
  }

  @override
  void dispose() 
  {
    isLoading = false;
    as.dispose();
    kontrollerPassword.dispose();
    kontrollerEmail.dispose();
    super.dispose();
  }

  Future<void> _register() async 
  {
    if (kontrollerEmail.text.isEmpty || kontrollerPassword.text.isEmpty) 
    {
      /* 
      await showDialog(
        context: context, 
        builder: (context) => AlertDialog(
          title: const Text(
            "Peringatan!",
            style: TextStyle(
              color: Color.fromARGB(255, 244, 67, 54),
              fontFamily: "Roboto",
              fontSize: 18.0,
              fontWeight: FontWeight.w600
            ),
          ),
          content: const Text(
            "Field tidak boleh kosong.",
            style: TextStyle(
              fontFamily: "Roboto",
              fontSize: 12.0,
              fontWeight: FontWeight.w300
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                textStyle: WidgetStateProperty.resolveWith<TextStyle>(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.pressed)) {
                      return const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500
                      );
                    }
                    return const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 12.0,
                      fontWeight: FontWeight.w300
                    );
                  }
                ),
                foregroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.pressed)) {return Colors.blue.shade700;}
                    return Colors.blue;
                  }
                ),
                shape: WidgetStateProperty.resolveWith<RoundedRectangleBorder>(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.pressed)) 
                    {
                      return RoundedRectangleBorder(
                        side: BorderSide(width: 2.0),
                        borderRadius: BorderRadiusGeometry.all(Radius.circular(16.0))
                      );
                    }
                    return RoundedRectangleBorder(
                      side: BorderSide(width: 1.0),
                      borderRadius: BorderRadiusGeometry.all(Radius.circular(8.0))
                    );
                  }
                ), 
                padding: WidgetStateProperty.resolveWith<EdgeInsets>(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.pressed)) {return EdgeInsets.symmetric(vertical: 14, horizontal: 26);}
                    return EdgeInsets.symmetric(vertical: 12, horizontal: 24);
                  }
                )
              ),
              onPressed: () => Navigator.pop(context), 
              child: const Text("Ok"))
          ],
        )
      ); 
      */
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.error_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: const Text(
                  "Tidak bisa registrasi data hantu, tolong diisi datanya!",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Roboto",
                    fontSize: 12.0,
                    fontWeight: FontWeight.w300
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2)
        )
      );
      return;
    }
    
    setState(() => isLoading = true);
    User? user = await as.register(
      kontrollerEmail.text.trim(), 
      kontrollerPassword.text.trim()
    );
    setState(() => isLoading = false);

    if (!mounted) {return;}

    if (user == null) 
    {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 5),
            const Text(
              "Register gagal",
              style: TextStyle(
                color: Colors.white,
                fontFamily: "Roboto",
                fontSize: 12.0,
                fontWeight: FontWeight.w300
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2)
      ));
      Navigator.pop(context);
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.check_circle_outline,
            color: Colors.white,
          ),
          const SizedBox(width: 5),
          const Text(
            "Register berhasil",
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Roboto",
              fontSize: 12.0,
              fontWeight: FontWeight.w300
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2)
    ));
  }

  void _goToLogin()
  {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => const LoginPage())
    );
  }
  
  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Register",
          style: TextStyle(
            fontFamily: "Roboto",
            fontSize: 18.0,
            fontWeight: FontWeight.w600
          ),
        ),
        automaticallyImplyLeading: false
      ),
      body: Padding(
        padding: const EdgeInsetsGeometry.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              "Buat Akun",
              style: TextStyle(
                fontFamily: "Roboto",
                fontSize: 18.0,
                fontWeight: FontWeight.w700
              )
            ),
            const SizedBox(height: 5),
            const Text(
              "Isi data terlebih dahulu sebelum masuk ke aplikasi!",
              style: TextStyle(
                fontFamily: "Roboto",
                fontSize: 12.0,
                fontWeight: FontWeight.w300
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              style: WidgetStateTextStyle.resolveWith(
                (Set<WidgetState> states)
                {
                  if (states.contains(WidgetState.focused)) 
                  {
                    return const TextStyle(
                      color: Color.fromARGB(255, 245, 0, 87),
                      fontFamily: "Roboto",
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500
                    );
                  }
                  return const TextStyle(
                    color: Color.fromARGB(255, 255, 64, 129),
                    fontFamily: "Roboto",
                    fontSize: 14.0,
                    fontWeight: FontWeight.w300
                  );
                }
              ),
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: WidgetStateTextStyle.resolveWith(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.focused)) 
                    {
                      return const TextStyle(
                        color: Color.fromARGB(255, 41, 184, 255),
                        fontFamily: "Roboto",
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500
                      );
                    }
                    return const TextStyle(
                      color: Color.fromARGB(255, 33, 173, 243),
                      fontFamily: "Roboto",
                      fontSize: 14.0,
                      fontWeight: FontWeight.w300
                    );
                  }
                ),
                hintText: "nama@alamat.com",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontFamily: "Roboto"),
                prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                border: WidgetStateInputBorder.resolveWith(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.focused)) 
                    {
                      return OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.deepPurple, width: 2.0)
                      );
                    }
                    return OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.grey.shade300)
                    );
                  }
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0)
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10)
              ),
              controller: kontrollerEmail,
            ),
            const SizedBox(height: 10),
            TextField(
              style: WidgetStateTextStyle.resolveWith(
                (Set<WidgetState> states)
                {
                  if (states.contains(WidgetState.focused)) 
                  {
                    return const TextStyle(
                      color: Color.fromARGB(255, 245, 0, 87),
                      fontFamily: "Roboto",
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500
                    );
                  }
                  return const TextStyle(
                    color: Color.fromARGB(255, 255, 64, 129),
                    fontFamily: "Roboto",
                    fontSize: 14.0,
                    fontWeight: FontWeight.w300
                  );
                }
              ),
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: WidgetStateTextStyle.resolveWith(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.focused)) 
                    {
                      return const TextStyle(
                        color: Color.fromARGB(255, 41, 184, 255),
                        fontFamily: "Roboto",
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500
                      );
                    }
                    return const TextStyle(
                      color: Color.fromARGB(255, 33, 173, 243),
                      fontFamily: "Roboto",
                      fontSize: 14.0,
                      fontWeight: FontWeight.w300
                    );
                  }
                ),
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey), // Added icon from photo
                border: WidgetStateInputBorder.resolveWith(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.focused)) 
                    {
                      return OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.deepPurple, width: 2.0)
                      );
                    }
                    return OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.grey.shade300)
                    );
                  }
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0)
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10)
              ),
              controller: kontrollerPassword,
              obscureText: true
            ),
            const SizedBox(height: 20),
            (isLoading) ? 
            const CircularProgressIndicator(trackGap: 1) : 
            ElevatedButton(
              style: ButtonStyle(
                textStyle: WidgetStateProperty.resolveWith<TextStyle>(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.pressed)) {
                      return const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500
                      );
                    }
                    return const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 12.0,
                      fontWeight: FontWeight.w300
                    );
                  }
                ),
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.pressed)) {return Colors.blue.shade700;}
                    return Colors.blue;
                  }
                ),
                foregroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.pressed)) {return Colors.white54;}
                    return Colors.white;
                  }
                ),
                shape: WidgetStateProperty.resolveWith<RoundedRectangleBorder>(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.pressed)) 
                    {
                      return RoundedRectangleBorder(
                        side: BorderSide(width: 2.0),
                        borderRadius: BorderRadiusGeometry.all(Radius.circular(16.0))
                      );
                    }
                    return RoundedRectangleBorder(
                      side: BorderSide(width: 1.0),
                      borderRadius: BorderRadiusGeometry.all(Radius.circular(8.0))
                    );
                  }
                ),
                padding: WidgetStateProperty.resolveWith(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.pressed)) {return EdgeInsets.symmetric(vertical: 14, horizontal: 26);}
                    return EdgeInsets.symmetric(vertical: 12, horizontal: 24);
                  }
                )
              ),
              onPressed: _register, 
              child: const Text("Register")
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  "Sudah Punya Akun?",
                  style: TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 12.0,
                    fontWeight: FontWeight.w300
                  ),
                ),
                const SizedBox(width: 5),
                TextButton(
                  style: ButtonStyle(
                    textStyle: WidgetStateProperty.resolveWith<TextStyle>(
                      (Set<WidgetState> states)
                      {
                        if (states.contains(WidgetState.pressed)) {
                          return const TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500
                          );
                        }
                        return const TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 12.0,
                          fontWeight: FontWeight.w300
                        );
                      }
                    ),
                    foregroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states)
                      {
                        if (states.contains(WidgetState.pressed)) {return Colors.blue.shade700;}
                        return Colors.blue;
                      }
                    ),
                    /*
                     shape: WidgetStateProperty.resolveWith<RoundedRectangleBorder>(
                      (Set<WidgetState> states)
                      {
                        if (states.contains(WidgetState.pressed)) 
                        {
                          return RoundedRectangleBorder(
                            side: BorderSide(width: 2.0),
                            borderRadius: BorderRadiusGeometry.all(Radius.circular(16.0))
                          );
                        }
                        return RoundedRectangleBorder(
                          side: BorderSide(width: 1.0),
                          borderRadius: BorderRadiusGeometry.all(Radius.circular(8.0))
                        );
                      }
                    ), 
                    */
                    padding: WidgetStateProperty.resolveWith<EdgeInsets>(
                      (Set<WidgetState> states)
                      {
                        if (states.contains(WidgetState.pressed)) {return EdgeInsets.symmetric(vertical: 14, horizontal: 26);}
                        return EdgeInsets.symmetric(vertical: 12, horizontal: 24);
                      }
                    )
                  ),
                  onPressed: _goToLogin, 
                  child: const Text("Login")
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget 
{
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> 
{
  late final TextEditingController kontrollerEmail;
  late final TextEditingController kontrollerPassword;
  late final AuthService as;
  late bool isLoading;

  @override
  void initState() 
  {
    super.initState();
    kontrollerEmail = TextEditingController();
    kontrollerPassword = TextEditingController();
    as = AuthService();
    isLoading = false;
  }

  @override
  void dispose() 
  {
    isLoading = false;
    as.dispose();
    kontrollerPassword.dispose();
    kontrollerEmail.dispose();
    super.dispose();
  }

  Future<void> _login() async 
  {
    if (kontrollerEmail.text.isEmpty || kontrollerPassword.text.isEmpty) 
    {
      /* 
      await showDialog(
        context: context, 
        builder: (context) => AlertDialog(
          title: const Text(
            "Peringatan!",
            style: TextStyle(
              color: Color.fromARGB(255, 244, 67, 54),
              fontFamily: "Roboto",
              fontSize: 18.0,
              fontWeight: FontWeight.w600
            ),
          ),
          content: const Text(
            "Field tidak boleh kosong.",
            style: TextStyle(
              fontFamily: "Roboto",
              fontSize: 12.0,
              fontWeight: FontWeight.w300
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                textStyle: WidgetStateProperty.resolveWith<TextStyle>(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.pressed)) {
                      return const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500
                      );
                    }
                    return const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 12.0,
                      fontWeight: FontWeight.w300
                    );
                  }
                ),
                foregroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.pressed)) {return Colors.blue.shade700;}
                    return Colors.blue;
                  }
                ),
                shape: WidgetStateProperty.resolveWith<RoundedRectangleBorder>(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.pressed)) 
                    {
                      return RoundedRectangleBorder(
                        side: BorderSide(width: 2.0),
                        borderRadius: BorderRadiusGeometry.all(Radius.circular(16.0))
                      );
                    }
                    return RoundedRectangleBorder(
                      side: BorderSide(width: 1.0),
                      borderRadius: BorderRadiusGeometry.all(Radius.circular(8.0))
                    );
                  }
                ), 
                padding: WidgetStateProperty.resolveWith<EdgeInsets>(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.pressed)) {return EdgeInsets.symmetric(vertical: 14, horizontal: 26);}
                    return EdgeInsets.symmetric(vertical: 12, horizontal: 24);
                  }
                )
              ),
              onPressed: () => Navigator.pop(context), 
              child: const Text("Ok"))
          ],
        )
      ); 
      */
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.error_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: const Text(
                  "Tidak bisa login dengan data hantu kecuali secara anonim, tolong diisi datanya!",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Roboto",
                    fontSize: 12.0,
                    fontWeight: FontWeight.w300
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2)
        )
      );
      return;
    }
    
    setState(() => isLoading = true);
    User? user = await as.login(
      kontrollerEmail.text.trim(), 
      kontrollerPassword.text.trim()
    );
    setState(() => isLoading = false);

    if (!mounted) {return;}

    if (user == null) 
    {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 5),
            const Text(
              "Login gagal",
              style: TextStyle(
                color: Colors.white,
                fontFamily: "Roboto",
                fontSize: 12.0,
                fontWeight: FontWeight.w300
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2)
      ));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.check_circle_outline,
            color: Colors.white,
          ),
          const SizedBox(width: 5),
          const Text(
            "Login berhasil",
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Roboto",
              fontSize: 12.0,
              fontWeight: FontWeight.w300
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2)
    ));
  }

  void _goToRegister()
  {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => const RegisterPage())
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Login",
          style: TextStyle(
            fontFamily: "Roboto",
            fontSize: 18.0,
            fontWeight: FontWeight.w600
          ),
        ),
        automaticallyImplyLeading: false
      ),
      body: Padding(
        padding: const EdgeInsetsGeometry.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              "Selamat Datang!",
              style: TextStyle(
                fontFamily: "Roboto",
                fontSize: 18.0,
                fontWeight: FontWeight.w700
              )
            ),
            const SizedBox(height: 5),
            const Text(
              "Login terlebih dahulu untuk masuk ke aplikasi!",
              style: TextStyle(
                fontFamily: "Roboto",
                fontSize: 12.0,
                fontWeight: FontWeight.w300
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              style: WidgetStateTextStyle.resolveWith(
                (Set<WidgetState> states)
                {
                  if (states.contains(WidgetState.focused)) 
                  {
                    return const TextStyle(
                      color: Color.fromARGB(255, 245, 0, 87),
                      fontFamily: "Roboto",
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500
                    );
                  }
                  return const TextStyle(
                    color: Color.fromARGB(255, 255, 64, 129),
                    fontFamily: "Roboto",
                    fontSize: 14.0,
                    fontWeight: FontWeight.w300
                  );
                }
              ),
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: WidgetStateTextStyle.resolveWith(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.focused)) 
                    {
                      return const TextStyle(
                        color: Color.fromARGB(255, 41, 184, 255),
                        fontFamily: "Roboto",
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500
                      );
                    }
                    return const TextStyle(
                      color: Color.fromARGB(255, 33, 173, 243),
                      fontFamily: "Roboto",
                      fontSize: 14.0,
                      fontWeight: FontWeight.w300
                    );
                  }
                ),
                hintText: "nama@alamat.com",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontFamily: "Roboto"),
                prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                border: WidgetStateInputBorder.resolveWith(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.focused)) 
                    {
                      return OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.deepPurple, width: 2.0)
                      );
                    }
                    return OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.grey.shade300)
                    );
                  }
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0)
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10)
              ),
              controller: kontrollerEmail,
            ),
            const SizedBox(height: 10),
            TextField(
              style: WidgetStateTextStyle.resolveWith(
                (Set<WidgetState> states)
                {
                  if (states.contains(WidgetState.focused)) 
                  {
                    return const TextStyle(
                      color: Color.fromARGB(255, 245, 0, 87),
                      fontFamily: "Roboto",
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500
                    );
                  }
                  return const TextStyle(
                    color: Color.fromARGB(255, 255, 64, 129),
                    fontFamily: "Roboto",
                    fontSize: 14.0,
                    fontWeight: FontWeight.w300
                  );
                }
              ),
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: WidgetStateTextStyle.resolveWith(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.focused)) 
                    {
                      return const TextStyle(
                        color: Color.fromARGB(255, 41, 184, 255),
                        fontFamily: "Roboto",
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500
                      );
                    }
                    return const TextStyle(
                      color: Color.fromARGB(255, 33, 173, 243),
                      fontFamily: "Roboto",
                      fontSize: 14.0,
                      fontWeight: FontWeight.w300
                    );
                  }
                ),
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey), // Added icon from photo
                border: WidgetStateInputBorder.resolveWith(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.focused)) 
                    {
                      return OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.deepPurple, width: 2.0)
                      );
                    }
                    return OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.grey.shade300)
                    );
                  }
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0)
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10)
              ),
              controller: kontrollerPassword,
              obscureText: true
            ),
            const SizedBox(height: 20),
            (isLoading) ? 
            const CircularProgressIndicator(trackGap: 1) : 
            ElevatedButton(
              style: ButtonStyle(
                textStyle: WidgetStateProperty.resolveWith<TextStyle>(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.pressed)) {
                      return const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500
                      );
                    }
                    return const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 12.0,
                      fontWeight: FontWeight.w300
                    );
                  }
                ),
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.pressed)) {return Colors.blue.shade700;}
                    return Colors.blue;
                  }
                ),
                foregroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.pressed)) {return Colors.white54;}
                    return Colors.white;
                  }
                ),
                shape: WidgetStateProperty.resolveWith<RoundedRectangleBorder>(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.pressed)) 
                    {
                      return RoundedRectangleBorder(
                        side: BorderSide(width: 2.0),
                        borderRadius: BorderRadiusGeometry.all(Radius.circular(16.0))
                      );
                    }
                    return RoundedRectangleBorder(
                      side: BorderSide(width: 1.0),
                      borderRadius: BorderRadiusGeometry.all(Radius.circular(8.0))
                    );
                  }
                ),
                padding: WidgetStateProperty.resolveWith<EdgeInsets>(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.pressed)) {return EdgeInsets.symmetric(vertical: 14, horizontal: 26);}
                    return EdgeInsets.symmetric(vertical: 12, horizontal: 24);
                  }
                )
              ),
              onPressed: _login, 
              child: const Text("Login")
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  "Belum punya akun?",
                  style: TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 12.0,
                    fontWeight: FontWeight.w300
                  ),
                ),
                const SizedBox(width: 5),
                TextButton(
                  style: ButtonStyle(
                    textStyle: WidgetStateProperty.resolveWith<TextStyle>(
                      (Set<WidgetState> states)
                      {
                        if (states.contains(WidgetState.pressed)) {
                          return const TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500
                          );
                        }
                        return const TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 12.0,
                          fontWeight: FontWeight.w300
                        );
                      }
                    ),
                    foregroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states)
                      {
                        if (states.contains(WidgetState.pressed)) {return Colors.blue.shade700;}
                        return Colors.blue;
                      }
                    ),
                   /*  
                   shape: WidgetStateProperty.resolveWith<RoundedRectangleBorder>(
                      (Set<WidgetState> states)
                      {
                        if (states.contains(WidgetState.pressed)) 
                        {
                          return RoundedRectangleBorder(
                            side: BorderSide(width: 2.0),
                            borderRadius: BorderRadiusGeometry.all(Radius.circular(16.0))
                          );
                        }
                        return RoundedRectangleBorder(
                          side: BorderSide(width: 1.0),
                          borderRadius: BorderRadiusGeometry.all(Radius.circular(8.0))
                        );
                      }
                    ), 
                    */
                    padding: WidgetStateProperty.resolveWith<EdgeInsets>(
                      (Set<WidgetState> states)
                      {
                        if (states.contains(WidgetState.pressed)) {return EdgeInsets.symmetric(vertical: 14, horizontal: 26);}
                        return EdgeInsets.symmetric(vertical: 12, horizontal: 24);
                      }
                    )
                  ),
                  onPressed: _goToRegister, 
                  child: const Text("Daftar")
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget 
{
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) 
  {
    final AuthService as = AuthService();
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home Page",
          style: TextStyle(
            color: Colors.red,
            fontFamily: "Roboto",
            fontSize: 18.0,
            fontWeight: FontWeight.w500
          ),
        ),
        automaticallyImplyLeading: false
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "Berhasil Login",
              style: TextStyle(
                fontFamily: "Roboto",
                fontSize: 16.0,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 5),
            Text("Selamat datang, ${user?.email}"),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ButtonStyle(
                textStyle: WidgetStateProperty.resolveWith<TextStyle>(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.pressed)) 
                    {
                      return const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600
                      ); // Pengaturan teks saat ditekan 
                    }

                    return const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 14.0,
                      fontWeight: FontWeight.w300
                    ); // Pengaturan teks default
                  }
                ),
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) 
                  {
                    if (states.contains(WidgetState.pressed)) {return Colors.red.shade700;} // Warna saat ditekan
                    return Colors.red; // Warna default
                  },
                ),
                foregroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states)
                  {
                    if (states.contains(WidgetState.pressed)) {return Colors.white54;} // Warna saat ditekan
                    return Colors.white; // Warna default
                  }
                ),
                shape: WidgetStateProperty.resolveWith<RoundedRectangleBorder>(
                  (Set<WidgetState> states)
                  {
                    if(states.contains(WidgetState.pressed))
                    {
                      return RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(16.0),
                        side: const BorderSide(
                          color: Color.fromARGB(255, 167, 106, 0),
                          width: 5
                        )
                      ); // Bentuk dialog saat ditekan
                    }
                    return RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(8.0),
                      side: const BorderSide(
                        color: Color.fromARGB(168, 212, 127, 0),
                        width: 1
                      )
                    ); // Bentuk dialog default
                  }
                )
              ),
              onPressed: () => as.logout(), 
              child: const Text("Logout")
            )
          ],
        ),
      ),
    );
  }
}