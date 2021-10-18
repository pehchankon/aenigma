package com.example.encrypto;
import java.security.*;
import javax.crypto.*;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

import android.app.Service;
import android.content.Intent;
import android.inputmethodservice.InputMethodService;
import android.inputmethodservice.Keyboard;
import android.inputmethodservice.KeyboardView;
import android.media.AudioManager;
import java.util.*;

import android.os.Build;
import android.os.IBinder;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.View;
import android.view.inputmethod.*;
import android.content.SharedPreferences;
import android.content.Context;
import androidx.annotation.RequiresApi;
import android.preference.PreferenceManager;

import android.os.CountDownTimer;
import android.view.ViewConfiguration;

public class keyboard extends InputMethodService implements KeyboardView.OnKeyboardActionListener {

    enum Mode
    {
        TEXT, NUMERIC, SYMBOL;
    }
    private long difference;
    private Mode state=Mode.TEXT;
    private Cryptography cryptoController = new Cryptography();
    private KeyboardView keyboardView;
    private Keyboard keyboard;
    CountDownTimer countDown;
    SharedPreferences prefs;
    String password="";
    private boolean changeKeyboardScreen=false;
    private boolean caps = false;

    @Override
    public View onCreateInputView() {
        countDown = new CountDownTimer(500, 100) {
            public void onTick(long millisUntilFinished) {
         }

        public void onFinish() 
        {
            InputMethodManager imeManager = (InputMethodManager) getApplicationContext().getSystemService(INPUT_METHOD_SERVICE);
            imeManager.showInputMethodPicker();
            changeKeyboardScreen=true;
        }
        };
        prefs=this.getSharedPreferences("FlutterSharedPreferences", 0);
        password=prefs.getString("flutter.activeKey", "");
        keyboardView = (KeyboardView) getLayoutInflater().inflate(R.layout.keyboard_view, null);
        keyboard = new Keyboard(this, R.xml.keys_layout);
        keyboardView.setKeyboard(keyboard);
        keyboardView.setOnKeyboardActionListener(this);
        keyboardView.setPreviewEnabled(false); 
        return keyboardView;
    }

    @Override
    public void onPress(int i) 
    {
        countDown.cancel();
        if(i==32)
        {
            countDown.start();
        }

    }
    @Override
    public void onRelease(int i) 
    {
        countDown.cancel();
        if(i==32&&changeKeyboardScreen==false)
        {
            InputConnection inputConnection = getCurrentInputConnection();
            inputConnection.commitText(" ", 1);
        }
        else
            changeKeyboardScreen =false;
    }


    @Override
    public void onKey(int primaryCode, int[] keyCodes) {
        InputConnection inputConnection = getCurrentInputConnection();
        if (inputConnection != null) {
            switch(primaryCode) {

                case Keyboard.KEYCODE_DELETE :
                    CharSequence selectedText = inputConnection.getSelectedText(0);

                    if(TextUtils.isEmpty(selectedText)) {
                        inputConnection.deleteSurroundingText(1, 0);
                    } else {
                        inputConnection.commitText("", 1);
                    }
                    break;

                case Keyboard.KEYCODE_SHIFT:
                    caps = !caps;
                    keyboard.setShifted(caps);
                    keyboardView.invalidateAllKeys();
                    break;

                case Keyboard.KEYCODE_DONE:     
                    inputConnection.sendKeyEvent(new KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_ENTER));
                    inputConnection.sendKeyEvent(new KeyEvent(KeyEvent.ACTION_UP, KeyEvent.KEYCODE_ENTER));
                    break;
                
                case -6:                        //decrypt/encrypt
                    password=prefs.getString("flutter.activeKey", "");
                    CharSequence currentText = inputConnection.getExtractedText(new ExtractedTextRequest(), 0).text;
                    String result="";
                    if(!currentText.toString().isEmpty()) 
                    {
                        if(!TextUtils.isEmpty(inputConnection.getSelectedText(0))) inputConnection.commitText("", 1);
                        inputConnection.deleteSurroundingText(Integer.MAX_VALUE, Integer.MAX_VALUE);
                        try {result = cryptoController.encrypt(currentText.toString(),password);} catch (Exception e) {}
                    } 
                    else
                    {
                        ClipboardManager clipboardManager;
                        clipboardManager = (ClipboardManager)getSystemService(Context.CLIPBOARD_SERVICE);
                        ClipData pData = clipboardManager.getPrimaryClip();
                        ClipData.Item item = pData.getItemAt(0);
                        String encryptedText = item.getText().toString();
                        try {result = cryptoController.decrypt(encryptedText,password);} catch (Exception e) {}
                    }
                    
                    // inputConnection.commitText(password + ' ',1);
                    inputConnection.commitText(result, 1);

                    break;

                case -7:            //change to number
                    keyboard = new Keyboard(this, R.xml.keys_layout2);
                    state=Mode.NUMERIC;
                    keyboard.setShifted(caps);
                    keyboardView.setKeyboard(keyboard);
                    keyboardView.invalidateAllKeys();

                    break;
                
                case -8:            //change to symbol
                    keyboard = new Keyboard(this, R.xml.keys_layout3);
                    state=Mode.SYMBOL;
                    keyboard.setShifted(caps);
                    keyboardView.setKeyboard(keyboard);
                    keyboardView.invalidateAllKeys();
                    break;

                case -9:            //change to alpha
                    keyboard = new Keyboard(this, R.xml.keys_layout);
                    state=Mode.TEXT;
                    keyboard.setShifted(caps);
                    keyboardView.setKeyboard(keyboard);
                    keyboardView.invalidateAllKeys();

                    break;

                case 32:
                    // difference=System.currentTimeMillis() - startTime;
                    // if(difference>700)
                    // {
                    //     InputMethodManager imeManager = (InputMethodManager) getApplicationContext().getSystemService(INPUT_METHOD_SERVICE);
                    //     imeManager.showInputMethodPicker();
                    // }
                    break;
                default :
                    char code = (char) primaryCode;
                    if(Character.isLetter(code) && caps){
                        code = Character.toUpperCase(code);
                    }
                    inputConnection.commitText(String.valueOf(code), 1);

            }
        }

    }

    @Override
    public void onText(CharSequence charSequence) {

    }

    @Override
    public void swipeLeft() {

    }

    @Override
    public void swipeRight() {

    }

    @Override
    public void swipeDown() {

    }

    @Override
    public void swipeUp() {

    }

}