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

import androidx.annotation.RequiresApi;

public class keyboard extends InputMethodService implements KeyboardView.OnKeyboardActionListener {

    enum Mode
    {
        TEXT, NUMERIC, SYMBOL;
    }
    private Cryptography cryptoController = new Cryptography();
    private KeyboardView keyboardView;
    private Keyboard keyboard;

    private boolean caps = false;

    @Override
    public View onCreateInputView() {
        keyboardView = (KeyboardView) getLayoutInflater().inflate(R.layout.keyboard_view, null);
        keyboard = new Keyboard(this, R.xml.keys_layout);
        keyboardView.setKeyboard(keyboard);
        keyboardView.setOnKeyboardActionListener(this);
        return keyboardView;
    }

    @Override
    public void onPress(int i) {}
    @Override
    public void onRelease(int i) {}


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

                case Keyboard.KEYCODE_DONE:     //encrypt and send
                    CharSequence currentText = inputConnection.getExtractedText(new ExtractedTextRequest(), 0).text;
                    if(!TextUtils.isEmpty(inputConnection.getSelectedText(0))) inputConnection.commitText("", 1);
                    inputConnection.deleteSurroundingText(Integer.MAX_VALUE, Integer.MAX_VALUE);
                    try {String encryptedText = cryptoController.encrypt(currentText.toString());
                    inputConnection.commitText(encryptedText, 1);
                    inputConnection.sendKeyEvent(new KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_ENTER));
                    inputConnection.sendKeyEvent(new KeyEvent(KeyEvent.ACTION_UP, KeyEvent.KEYCODE_ENTER));
                    } catch (Exception e) {}
                    break;
                
                case -6:   
                    ClipboardManager clipboardManager;
                    clipboardManager = (ClipboardManager)getSystemService(Context.CLIPBOARD_SERVICE);
                    ClipData pData = clipboardManager.getPrimaryClip();
                    ClipData.Item item = pData.getItemAt(0);
                    String encryptedText = item.getText().toString();

                    try {
                    String decryptedString = cryptoController.decrypt(encryptedText);
                    inputConnection.deleteSurroundingText(Integer.MAX_VALUE, Integer.MAX_VALUE);
                    inputConnection.commitText(decryptedString, 1);
                    } catch (Exception e) {}
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