// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

enum Types { error, success, info, warning, none }
enum Animations {fromRight, fromLeft, fromTop, fromBottom, grow, shrink }
enum ButtonsDirection {row, column}
const EdgeInsets defaultAlertPadding = EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0);
const String images = "assets/images";
typedef AlertAnimation = Widget Function(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child);

class AlertStyle
{
  final Animations animationType;
  final Duration animationDuration;
  final ShapeBorder? alertBorder;
  final bool isButtonVisible;
  final bool isCloseButton;
  final bool isOverlayTapDismiss;
  final Color? backgroundColor;
  final Color overlayColor;
  final TextStyle titleStyle;
  final TextStyle descStyle;
  final TextAlign titleTextAlign;
  final TextAlign descTextAlign;
  final EdgeInsets buttonAreaPadding;
  final BoxConstraints? constraints;
  final ButtonsDirection buttonsDirection;
  final double? alertElevation;
  final EdgeInsets alertPadding;
  final AlignmentGeometry alertAlignment;

  /// Alert style constructor function
  /// The [animationType] parameter is used for transitions. Default: "fromBottom"
  /// The [animationDuration] parameter is used to set the animation transition time. Default: "200 ms"
  /// The [alertBorder] parameter sets border.
  /// The [isButtonVisible] paramater is used to decide hide or display buttons
  /// The [isCloseButton] parameter sets visibility of the close button. Default: "true"
  /// The [isOverlayTapDismiss] parameter sets closing the alert by clicking outside. Default: "true"
  /// The [backgroundColor] parameter sets the background color.
  /// The [overlayColor] parameter sets the background color of the outside. Default: "Color(0xDD000000)"
  /// The [titleStyle] parameter sets alert title text style.
  /// The [titleTextAlign] parameter sets alignment of the title.
  /// The [descStyle] parameter sets alert desc text style.
  /// The [descTextAlign] parameter sets alignment of the desc.
  /// The [buttonAreaPadding] parameter sets button area padding.
  /// The [constraints] parameter sets Alert size.
  /// The [buttonsDirection] parameter sets button box as Row or Col.
  /// The [alertElevation] parameter sets elevation of alert dialog box.
  /// The [alertPadding] parameter sets alert area padding.
  const AlertStyle({
    this.animationType = Animations.fromBottom,
    this.animationDuration = const Duration(milliseconds: 200),
    this.alertBorder,
    this.isButtonVisible = true,
    this.isCloseButton = true,
    this.isOverlayTapDismiss = true,
    this.backgroundColor,
    this.overlayColor = Colors.black54,
    this.titleStyle = const TextStyle(
        fontSize: 24,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal),
    this.titleTextAlign = TextAlign.center,
    this.descStyle = const TextStyle(
        fontSize: 18,
        color: Colors.black87,
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal),
    this.descTextAlign = TextAlign.center,
    this.buttonAreaPadding = const EdgeInsets.all(20.0),
    this.constraints,
    this.buttonsDirection = ButtonsDirection.row,
    this.alertElevation,
    this.alertPadding = defaultAlertPadding,
    this.alertAlignment = Alignment.center,
  });
}

class Alert {
  final String? id;
  final BuildContext context;
  final Types? type;
  final AlertStyle style;
  final Widget? image;
  final String title;
  final String? desc;
  final Widget? content;
  final List<DialogButton>? buttons;
  final Function? closeFunction;
  final Icon? closeIcon;
  final bool onWillPopActive;
  final AlertAnimation? alertAnimation;

  /// Alert constructor
  ///
  /// [context], [title] are required.
  Alert({
    required this.context,
    this.id,
    this.type,
    this.style = const AlertStyle(),
    this.image,
    required this.title,
    this.desc,
    this.content,
    this.buttons,
    this.closeFunction,
    this.closeIcon,
    this.onWillPopActive = false,
    this.alertAnimation,
  });

  /// Displays defined alert window
  Future<bool?> show() async {
    return await showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext buildContext, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return _buildDialog();
        },
        barrierDismissible: style.isOverlayTapDismiss,
        barrierLabel:
        MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: style.overlayColor,
        useRootNavigator: true,
        transitionDuration: style.animationDuration,
        transitionBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
            ) =>
        alertAnimation == null
            ? _showAnimation(animation, secondaryAnimation, child)
            : alertAnimation!(
            context, animation, secondaryAnimation, child));
  }

  // Will be added in next version.
  Future<void> dismiss() async {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // Alert dialog content widget
  Widget _buildDialog()
  {
    final Widget myChild = ConstrainedBox(
      constraints: style.constraints ??
          BoxConstraints.expand(width: double.infinity, height: double.infinity), child: Align(alignment: style.alertAlignment,
//          child: SingleChildScrollView(
      child: AlertDialog(
          backgroundColor: style.backgroundColor ??
              Theme.of(context).dialogBackgroundColor,
          shape: style.alertBorder ?? _defaultShape(),
          insetPadding: style.alertPadding,
          elevation: style.alertElevation,
          titlePadding: const EdgeInsets.all(0.0),
          title: Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _getCloseButton(),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        20, (style.isCloseButton ? 0 : 10), 20, 0),
                    child: Column(
                      children: <Widget>[
                        _getImage(),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          title,
                          style: style.titleStyle,
                          textAlign: style.titleTextAlign,
                        ),
                        SizedBox(
                          height: desc == null ? 5 : 10,
                        ),
                        desc == null
                            ? Container()
                            : Text(
                          desc!,
                          style: style.descStyle,
                          textAlign: style.descTextAlign,
                        ),
                        content == null ? Container() : content!,
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          contentPadding: style.buttonAreaPadding,
          content: style.buttonsDirection == ButtonsDirection.row
              ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _getButtons(),
          )
              : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _getButtons(),
          )),
    ),
//      ),
    );
    return onWillPopActive
        ? WillPopScope(onWillPop: () async => false, child: myChild)
        : myChild;
  }

// Returns the close button on the top right
  Widget _getCloseButton() {
    return style.isCloseButton
        ? Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
      child: GestureDetector(
        onTap: () {
          if (closeFunction == null) {
            Navigator.of(context, rootNavigator: true).pop();
          } else {
            closeFunction!();
          }
        },
        child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(
          alignment: FractionalOffset.topRight,
          child: closeIcon != null
              ? Container(child: closeIcon)
              : Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: MemoryImage(Base64Codec().decode("iVBORw0KGgoAAAANSUhEUgAAAA8AAAAOCAYAAADwikbvAAAAAXNSR0IArs4c6QAAAPZJREFUKBVjrJm0QPnH979B/5mZDvSWJJ5mIACKe+abMv7958DBybyO6c+fP4xA9dxAAe+yvoVm+PSC5EHqQOpB+pg6ilLuMLGybANp+vf7jxcuA0DiIHmQOpB6kD6QrWCALtlVFH+KkBxcM0ghNgOwicEMRdGMbgAjI9PV////aYPEQU5Fdg1IDEMzSBDZNhAfm0awOIggFzCha0S2FeRskDyuWEDRjKwR5NTussTVIBqXAXA/o2tEDhxccmDNuCSRvYRNDWNF3xyVP78ZY0AKcYUqzBBkA1hY/y9hYmFh+Q+U/ArMGFuRnQrTgEyD5EHqQOpB+gDHHbKmz28GFAAAAABJRU5ErkJggg=="))/*AssetImage('$images/close.png')*/,
              ),
            ),
          ),
        ),
      ),
    ))
  : Container();
  }

  // Returns defined buttons. Default: Cancel Button
  List<Widget> _getButtons() {
    List<Widget> expandedButtons = [];
    if (style.isButtonVisible) {
      if (buttons != null) {
        for (var button in buttons!) {
            var buttonWidget = Padding(
              padding: const EdgeInsets.only(left: 2, right: 2),
              child: button,
            );
            if ((button.width != null && buttons!.length == 1) ||
                style.buttonsDirection == ButtonsDirection.column) {
              expandedButtons.add(buttonWidget);
            } else {
              expandedButtons.add(Expanded(
                child: buttonWidget,
              ));
            }
          }
      } else {
        Widget cancelButton = DialogButton(
          child: Text(
            "CANCEL",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
        );
        if (style.buttonsDirection == ButtonsDirection.row) {
          cancelButton = Expanded(
            child: cancelButton,
          );
        }
        expandedButtons.add(cancelButton);
      }
    }
    return expandedButtons;
  }

  // Returns alert default border style
  ShapeBorder _defaultShape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
      side: BorderSide(
        color: Colors.blueGrey,
      ),
    );
  }

  // Returns alert image for icon
  Widget _getImage() {
    Widget response = image ?? Container();
    switch (type) {
      case Types.success:
        // response = Image.asset('$images/icon_success.png');
        response = Image.memory(Base64Codec().decode("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"));
        break;
      case Types.error:
        // response = Image.asset('$images/icon_error.png');
        response = Image.memory(Base64Codec().decode("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"));
        break;
      case Types.info:
        // response = Image.asset('$images/icon_info.png');
        response = Image.memory(Base64Codec().decode("iVBORw0KGgoAAAANSUhEUgAAAGAAAABgCAYAAAGVn0euAAAABGdBTUEAALGPC/xhBQAAEDtJREFUeAHtXWuMlNUZPueb2Quyy2V3tiwrsWi00JBKTdGqwO4qTdNaoU2Nl9aI1x/V/tEfFdTaUNtatEkxTdP2hxeUaIrGRpFaNVbZAbzSCLRE16WCFpYlO8NtF1nYnTl9njPzzc7sfPNdZr65yUyyO993Lu973ufc3vOe95wRwuIzs2fw+vaeyMmZWwYXWESPB7VvGnxg/G38CeEj42/5PLWHB3/pJt+MTYMqZ7qObeoMq0iDAlpFxIYjx63CDSXk41YRucIMGVALc0V6CrcV0C3OM3oicddckXhlVuJcxXCkjAQ78bc1i2J6QEc48v30d9tnFGXINgEi2zdFLnRKYx2Psr5uHZMdmguU7JSlDYEMMbcc0YROuE2bma6jJ/rtzJAC3lYpZbjOjtr9j1M9EYOOnsEfuybqplnlIjb7g8PTcsLhqXHn4pAMbw9HLspIQigyAmxevDRXpZS0IVV4lJ46UEk7vZDyIgHpskk5jhVeClBwWi8SAKLNmqGXduyWgWWHYzsuWEQQQKvck5MOx2b+5UxgE2FL2Cof2zEhyaVPEGOnIdBVR5izZbD5aEw8KpRcgoKg1al1A91tv7AqlOuwq5UKsPTzdqmmXJmgqC13W+kZNLxmmr1HNQL/SAaRXC/tPYN/zxXnFO5YsPZN0YediDjF52SCMemUU2a38VlMELDdbWa36dhImDYxf0rjD24ysmRo94Nu0oZ7ImM6XUc4epubDExD3XvWW2qS2/Q6XRZennLbJwbt3xtSyOfsk43HeoEomesuIyiNX42T8P/JmBqa3us/2XGKxuHo4byG5nES9k9GTMX+ZJ+ksFhDKHF+YSRscgcCS4OTmwK+TJMT2Zz5TnTW/otbNhqfLGg5OqNn8OOJCQp9HxuJ/y9FAwrrpakXHx5m9Rw9L4uMnz2aPTiLAQP8YOI47BfCxO1IKzCZPzYjfOg6SzEtAtFI/tux7VjIIso+CPPzeop8bp9qmJiyffNgN6Vt7zl0xcS49HdXelF6honPnE9icfUX6EoBEIPJSL4kpXoxIAI7VWOwf1pT81D02JEOY1SdGVPx7yDdMrNzSynCZ0wOLGNXmUjX7btnAYAKp+/5Qhq3Huxq9WQSylWob2xTdfuOR3ZBsPMC0ljY39X6Vq60eYWjTb3r2LrzomydaWY4eqduPm8fnm2dwmUoCh33Q9VzyS4rmbl26Nh86EdZkcmAoFUEEUdbjQx0hdwbNawIFRgm0ZlAQnYrFYyhQ89qCtX/a4EctSVbyDhnS9iHSLSIVzlEWpIyF0uWkRUUyPEdIPdlFakYyJMm/1zPQFmlsg5ALazgHMJYPYzO2BQZC7W1Tts1Tw5bZ6m8UI6KzQ0yFNSL9zE1WozCm7UKlCIwCLT5CUNzR2vzUH/0hEHLA2ZE16szPwtRCK3d58mTAiYa6OxyidHY8EohxMqZV1saY/FYczkLUQhvCKDWiZNjtxRCpJx5DVrbMN3dX85C5MOb6jbybdeqAtVajK3L8yFUrjwqJt482N12gRZgoKutC4rTk1Rry1UgL3wB9qdSBr6XlYfjNk2eWREVFMDl34ye6K05i0R7LfXxnAnKGEGAXa1d27GQYGLq42Usb4o1mszavPQpLiQoCPXxFLUSPrDgvqwE2bkpCPXxYpefZqUEr8E1ReGVXDf0kQkQWlEoE1rxOKokCm3TOXMw8qWNn/tOdMrQSHyVkPJOKlg5eKUH7xCBwM8PLm7ZmB6Yz7MbZq7p0gdJjYllSsolWM12YLXRAVPJEETql0J9CGYbpgTEht5Fbb7t9BYkwDnbDk39/Hhsg1KiU0spBfa45QbYdl6J18n9rVOm9R8ZHmqWI2MdMRE7H5UD3xe1FKoL5hoZCxjyJ/2drY+6RsgiYV4CcJc5psTTaDJxELgZ1ounLGjbBnGjMhKJvoAmtwR7LbsWd7XOf05K194oJnFPAtCQDfPgVjSNvlmTQ/McTRwmF4dvzKy3CBWntWEH9JuvOyTPLxojRRSTyUgxVQ3Qf4CjkZ+eKMKclUupXnDyAmAwrhX4obMOEfHL4cFLcbg1Dt75j1amGlFOfYh2WdRG3IvgOi09P4i854xFyKCF8FITpt5TLgXOCgM2J9d9gshn+ZBZUS1xGDu24+gEKR8rhcaZr+y2zboarNPJeYJbXNkfSNfnZWsym0JpQlgLpktMiiOHStvqSaX09kCaftOl2oFRMuXWqc0qM8ORv2I7Z6W34pUnNXdGlVDzMrj7jZJJnH5Gufz8zTT5fGOgeT3l78TVFIeofAiVKw9VcW7KkL/BpSA2A39brsLkwzexGZPwbQtyHds0s3VSPoSc8phNEzq+p3WHE13Gg+AId5ewwaGk3u1wk6ui0siXjsXEMj0KVVS5XBaGDiXQNqtXAO0NI+RXq7YG6MpD003VCkA/JPRkdOIq/dCJCkaz/qoVgB5gtPhVrQB0X5NK/bNqBaDvnQyKDRRge3LLsrp6A7yCDyxq22bAzH2/iImiumkXExmDNnrMaIuKycRv2li7L+feNunqPkDFiDslfjMqFj0A/gT9TVMCCBm4KnZS2R9sLVZpPNLVm/E4YWk6y+oaGOhqeRnr4rNWeTl66ZGxX8npIAsX4exD29z95i64X4yKQYemfXONYdLXNcAXLJaxwSDPtvSeN1OX+Xvk08gRuianFyNjAzswuf5Lo8MneZrI9xVUOtN8nrk/oeJq2NGvGs1oDewue/JhUqw83J+Y2HRMXqkmZAYc7Gq7C9N0E8batWZYOb9pdDtxdOywbAie7akcNLXgr+zGLiKf81i3k0QUolw1wf0JXXgbz3Wn8ut4urmUuk9wf4KF506Rq0I6JWLHJsFSDLGo9VfJy3f3N3pKgXick10xZuykVzo9YLjhXbyPnrFZvXCR8UMBBJ0VRBx/fVl2fxdi5D1h6eNRKvY8NMNGENkiAuL+gcVtm5x48sjV8IHIvRgd74FVsA5q8bMHOkPXJU9rOGXPis9bgHRKMzYfulLEYr9G2Pz0cMtnHitR6pHmRmPV7otbj1mm8RDoiwAe+OVMqp2mRmUngLgciS6D0Xk+BPWnfAnQdoDum1iBvtFcp8J+gJdTGA8R/gjogSE1g5nhw98VInYj7FLL2IV0dilHYSWhfwdAEm80tYfe9storrvdQOQSLP115cKh7JvsfuQLAEbwb4MQgScPdE7/R75dUcuQx7+iVwAHxnD40E1wZ6JWdS7LCCE/w9efAg3y6f0Xt+5jWLk+nAiwmOb67g6uSZPl2I2Dlqs7O1vW5uND5kWWolQAp+z48VMPoXXfrIcRKT6B1eC+2xdPfxa7cd59Z7xIVGDaVTAK/Hnz4WuEiv0GPfQctBaOg08Yk+tX9C+Y4u4SEA9l8K0CqHjtG448BN5YDOEj5Wt1dXU/3Xfp1N36vUr/UXkdFaN/REMyb91ag/OcK/xydiy4AhLqunoZrT0E18+9wPmage7Q+1WKt22xtQtVXKyHGjQbwKE3yCvKJqt2B+SKOaFUr+0u0+kCW8SKFElZucjWCwBgYHdU26kInnsATQMxoTaiS9ZhmLnnYFdotROTL3K8NtkoOJlAiwsIeSUsbq95kdd1BdD1GEcV39dDjZRQ2VpvLrXK5kWwUqZNqNbRJ/B9ox6aGoIXDlwyfa+bMmRZFK0y0ZqiTo7twZg3PGlqcDqOCdxUA38cKWJBTIgNMSJWxGw8Re4n2x6QVCd7UbMthmHchVb/SG5StRgTAW4AxOPxNVBKokZT/Vw79TVnBegzJkJtwer0VFDWf21f19TsCxxMjrXvLASovo6pU//Gqrsec8OiXLsxlhVAkyFWro9iif7JpLNC8/aeLUeyONQCHBHgRuSJz/RVQ1jQGbcl9h4zs2VVwPixMNF3e2do7qoKXblSBUwXBYL4ft9GOv18n1dxZR2OfIRVNe57Etf3d7U9k04rYxKmjZln8jCpfMajbZUKfroAlf5MDIklMSW2E685S1UAT3LC/vG8QAYYyRb6tdSudIBKUT5iSUyJLTHWWE9kjKNNPclV7fKJcbV3fxDA6llfH0ysMyhyR0iDb95CnRFbe/ETAWyzb9YmDO7C4ZNwrklsx2FPonrutKG/QCYwMgrD2NzMsAp8I8a4xgY7f/QL3Sh57UB8TLwPlXMn/Gqc90QrRKZq0YKs4MIqeQe0ovONoLjQ4J0PTISt5hetEtfCioGAxBYoXMiAvYGV2rf4YhiBot/xQj61D0Z63BFCHHjZiYGWP5MvvDSE37VP8REwsU4cV+JVM/jwxpbis65xyMAa2OPMZOLXW3hdTg2e0iCQwhrYYw4QuuXzrqLSsK9xMbEm9vi9CvUhIeFFUTVoSoOAiTWxRwXQKwwzsr6lqzQFON25mFgTe4N3u8FIBNOuWmr1YwWnO1h+y5/AWC0l5sTe0BfrwdsXNdA4vD9yn98Ma/QyESDGxBpDziPEXpuj6WqNtXAMC4OVdj8Glkmq9uYVAWJLjIl1AvPkcVW6avNmRvr66AsOvVKupXeFQPLyyDpibbrHpzZkeC0mT0ugEpbw2IcrirVErhHQmPLmTmCcfgVpqgJISR9VwdWecENZzauqXFOvJbRFgFgSU16bSozTE2dUAB2MeK8qEuzm9aSVfClboKmhLf0vWF8/J12wSnnWGCauet1NbImxY9l4qAL29u3JXbIHHDPUElgikLx2kCf4tudzgi/xq2k8AliC68gtJajiQPPAKsZ+23OfWIzZf3h9J37M7QUsHHCGSywsmz+8fTErJpZnCHBH+BZqlNB2ftDfGbLd6MqYA6ykIAH+whdq6gMcTHiPF8N2n0ZnAawwsQojJsQGl0K8S6yImRP4pOPYA9KZ8TQMKuENhDVJYfxuoLv17vT40/WZVy4rEf8Z5B+GpnN50UeJ5OmYeGKSBnO/zvNWUQ1S5uRd15wj4/mekvHUAybio0/LqPjzCG/CAuPlxinB6/deMP3IxHRfpHde3zJybOwZjPM46yyGsb97lddTMel4FFQBJiF9euZUbD1axUWcrA0p7/6inSXQPv9KPczJFbr8e6I+cK3bUzAmTlbfvlRAOmFqTXElHkdltID4ScQ93Pjl0IN7q8zFna7luCbqXpT/bqycGvRhC0Pc6mZiTcfD6dn3CkhnqA95qDh/nTzh8CUFDnkYq2dNbllXac6/+pzz8UM3wD9kJV3Jk3LswBBzR67DFemy5vtc1ApILxRXglvDkWvjSt4LTSpxm3ji7MGbKMRTraHWvxXj9zrTy2A+0ywcjUR/iJZNR+TLMKxodZy2GvjpPLiwM7S+2FcUmGUpWQWYDNO/6aY98rm6Oq7iN0CpWIhduYAZj4KNYNP6Y1wU0IvwjzDJ9+KX9fYaShwbq5dDASMwpG/SRQZ6GfDXMoOnVDN+bGiKUrHZmCRhG5JzlVRzsID8it4EMYnDHg+TzFZDGusaz5DPmRcZpqJL+FDWCrCTk/eM4zKeOfAWmKPBlPgWkldsNgNQutA0YxWTcKVJuNbwZ7T4QzRD2Ozeh2EEFSZ64XDcO0WIXj9/Usuu3F7j/g/hM2PbnYuZowAAAABJRU5ErkJggg=="));
        break;
      case Types.warning:
        // response = Image.asset('$images/icon_warning.png');
        response = Image.memory(Base64Codec().decode("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"));
        break;
      case Types.none:
        response = Container();
        break;
      default:
        response = Container();
        break;
    }
    return response;
  }

  // Shows alert with selected animation
  _showAnimation(animation, secondaryAnimation, child)
  {
    switch (style.animationType) {
      case Animations.fromRight:
        return AnimationTransition.fromRight(
            animation, secondaryAnimation, child);
      case Animations.fromLeft:
        return AnimationTransition.fromLeft(
            animation, secondaryAnimation, child);
      case Animations.fromBottom:
        return AnimationTransition.fromBottom(
            animation, secondaryAnimation, child);
      case Animations.grow:
        return AnimationTransition.grow(animation, secondaryAnimation, child);
      case Animations.shrink:
        return AnimationTransition.shrink(animation, secondaryAnimation, child);
      case Animations.fromTop:
        return AnimationTransition.fromTop(
            animation, secondaryAnimation, child);
    }
  }
}

class DialogButton extends StatelessWidget {
  final Widget child;
  final double? width;
  final double height;
  final Color? color;
  final Color? highlightColor;
  final Color? splashColor;
  final Gradient? gradient;
  final BorderRadius? radius;
  final Function onPressed;
  final BoxBorder? border;
  final EdgeInsets padding;
  final EdgeInsets margin;

  /// DialogButton constructor
  DialogButton({
    Key? key,
    required this.child,
    this.width,
    this.height = 40.0,
    this.color,
    this.highlightColor,
    this.splashColor,
    this.gradient,
    this.radius,
    this.border,
    this.padding = const EdgeInsets.only(left: 6, right: 6),
    this.margin = const EdgeInsets.all(6),
    required this.onPressed,
  }) : super(key: key);

  /// Creates alert buttons based on constructor params
  @override
  Widget build(BuildContext context)
  {
    Widget button = Container(
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
          color: color ?? Theme.of(context).colorScheme.primary,
          gradient: gradient,
          borderRadius: radius ?? BorderRadius.circular(6),
          border: border ?? Border.all(color: Colors.transparent, width: 0)),
      child: Center(child: child));

    return GestureDetector(onTap: onPressed as void Function()?, child: MouseRegion(cursor: SystemMouseCursors.click, child: button));
  }
}

class AnimationTransition {
  /// Slide animation, from right to left (SlideTransition)
  static fromRight(Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  /// Slide animation, from left to right (SlideTransition)
  static fromLeft(Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1.0, 0.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  /// Slide animation, from top to bottom (SlideTransition)
  static fromTop(Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, -1.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  /// Slide animation, from top to bottom (SlideTransition)
  static fromBottom(Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  /// Scale animation, from in to out (ScaleTransition)
  static grow(Animation<double> animation, Animation<double> secondaryAnimation,
      Widget child) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Interval(
            0.00,
            0.50,
            curve: Curves.linear,
          ),
        ),
      ),
      child: child,
    );
  }

  /// Scale animation, from out to in (ScaleTransition)
  static shrink(Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 1.2,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Interval(
            0.50,
            1.00,
            curve: Curves.linear,
          ),
        ),
      ),
      child: child,
    );
  }
}
