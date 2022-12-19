// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';
import 'package:fml/log/manager.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:fml/helper/helper_barrel.dart';

// Json web token - oauth2
class Jwt
{
  bool valid = false;
  final String token;
  final Map<String, String> claims = Map<String, String>();

  Jwt(this.token, {bool validate = false})
  {
    valid = false;
    try
    {
      var parts = token.split(".");
      Map json = jsonDecode(S.fromBase64(parts[0])!);
      json.forEach((key, value)
      {
        claims[key] = value.toString();
      });

      json = jsonDecode(S.fromBase64(parts[1])!);
      json.forEach((key, value)
      {
        claims[key] = value.toString();
      });

      valid = true;
    }
    catch(e)
    {
      Log().exception(e);
    }
  }

  factory Jwt.encode(String key, Map<String, String?> claims, {String subject = "jwt", String issuer = "fml.client", List<String>? audience, int shelflife = 60})
  {
    // we could have done this quite simply ourselves, however, for the sake of time, use package
    // future todo - encode ourselves
    final _claims = JwtClaim(subject: subject, issuer: issuer, audience: audience, otherClaims: claims, maxAge: Duration(minutes: shelflife));
    String token = issueJwtHS256(_claims, key);
    return new Jwt(token, validate: false);
  }

  factory Jwt.decode(String token, {bool validate = true})
  {
    return Jwt(token, validate: validate);
  }
}