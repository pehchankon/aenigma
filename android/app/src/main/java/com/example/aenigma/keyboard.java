package com.pehchankon.aenigma;

import android.graphics.Color;

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
import android.view.Window;
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
import android.widget.Toast;
import android.os.Handler;
import android.os.Looper;
import android.widget.TextView;
import android.widget.EditText;
import android.text.Editable;

public class keyboard extends InputMethodService implements KeyboardView.OnKeyboardActionListener {

    enum Mode {
        TEXT, NUMERIC, SYMBOL;
    }

    float counter = 0;
    private long difference;
    private Mode state = Mode.TEXT;
    private Cryptography cryptoController = new Cryptography();
    private KeyboardView keyboardView;
    private View view;
    private Keyboard keyboard;
    CountDownTimer countDown;
    SharedPreferences prefs;
    private static String password;
    private static String keyAlias = "placeholder";
    private boolean changeKeyboardScreen = false;
    private boolean caps = false;
    private EditText editText;
    private static boolean encryptBuffer = true;
    InputConnection bufferIC;
    private static int timerValue = 0;
    private static boolean timerState = false;
    private static CountDownTimer deleteKeyCounter = new CountDownTimer(timerValue, 1000) {

        public void onTick(long millisUntilFinished) {
        }

        public void onFinish() {
            deleteKey();
        }

    };

    @Override
    public void onStartInputView(EditorInfo editorInfo, boolean restarting) {
        encryptBuffer = prefs.getBoolean("flutter.bufferInput", false);

        deleteKeyCounter.cancel();
        if (encryptBuffer) {
            editText.setFocusable(true);
            editText.requestFocus();
            editText.setTextIsSelectable(true);
        } else {
            editText.setText("");
            editText.setTextIsSelectable(false);
            editText.setFocusable(false);
        }
        editText.setHint(password == null ? "No key selected." : "Active Key Alias: " + keyAlias);
        editText.setHintTextColor(password == null ? Color.RED : Color.GREEN);
    }

    @Override
    public void onFinishInputView(boolean finishingInput) {
        deleteKeyCounter.cancel();
        editText.setHint("hellooo");
        if (password != null && timerState)
            deleteKeyCounter.start();
    }

    @Override
    public View onCreateInputView() {

        countDown = new CountDownTimer(500, 100) {
            public void onTick(long millisUntilFinished) {
            }

            public void onFinish() {
                InputMethodManager imeManager = (InputMethodManager) getApplicationContext()
                        .getSystemService(INPUT_METHOD_SERVICE);
                imeManager.showInputMethodPicker();
                changeKeyboardScreen = true;
            }
        };
        prefs = this.getSharedPreferences("FlutterSharedPreferences", 0);
        // password=prefs.getString("flutter.activeKey", "");
        // et.setTextIsSelectable(true);
        // et.setFocusable(true);
        // et.setFocusableInTouchMode(true);
        view = getLayoutInflater().inflate(R.layout.keyboard_view, null);
        keyboardView = view.findViewById(R.id.keyboard);
        editText = view.findViewById(R.id.buffer_input);
        bufferIC = editText.onCreateInputConnection(new EditorInfo());
        keyboard = new Keyboard(this, R.xml.keys_layout);
        keyboard.setShifted(caps);
        keyboardView.setKeyboard(keyboard);
        keyboardView.setOnKeyboardActionListener(this);
        keyboardView.setPreviewEnabled(false);

        return view;
    }

    @Override
    public void onPress(int i) {
        countDown.cancel();
        if (i == 32) {
            countDown.start();
        }

    }

    private static void deleteKey() {
        if(timerState) password = null;
    }

    @Override
    public void onRelease(int i) {
        countDown.cancel();
        if (i == 32 && changeKeyboardScreen == false) {
            InputConnection ic = encryptBuffer ? bufferIC : getCurrentInputConnection();
            ic.commitText(" ", 1);
        } else
            changeKeyboardScreen = false;
    }

    @Override
    public void onKey(int primaryCode, int[] keyCodes) {
        InputConnection inputConnection = getCurrentInputConnection();
        if (inputConnection != null) {
            switch (primaryCode) {

                case Keyboard.KEYCODE_DELETE:
                    InputConnection ic = encryptBuffer ? bufferIC : inputConnection;
                    // CharSequence selectedText = inputConnection.getSelectedText(0);
                    CharSequence selectedText = ic.getSelectedText(0);
                    // bufferIC.commitText(selectedText, 1);
                    // String selectedText = buffer.toString();
                    if (TextUtils.isEmpty(selectedText)) {
                        ic.deleteSurroundingText(1, 0);
                    } else {

                        ic.commitText("", 1);
                    }
                    break;

                case Keyboard.KEYCODE_SHIFT:
                    caps = !caps;
                    keyboard.setShifted(caps);
                    keyboardView.invalidateAllKeys();
                    break;

                case Keyboard.KEYCODE_DONE:
                    if (encryptBuffer) {
                        bufferIC.commitText("\n", 1);
                        // bufferIC.sendKeyEvent(new KeyEvent(KeyEvent.ACTION_DOWN,
                        // KeyEvent.KEYCODE_ENTER));
                        // bufferIC.sendKeyEvent(new KeyEvent(KeyEvent.ACTION_UP,
                        // KeyEvent.KEYCODE_ENTER));
                    } else {
                        // inputConnection.commitText("\n",1);
                        inputConnection.sendKeyEvent(new KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_ENTER));
                        inputConnection.sendKeyEvent(new KeyEvent(KeyEvent.ACTION_UP, KeyEvent.KEYCODE_ENTER));
                    }
                    break;

                case -6: // decrypt/encrypt
                    // password=prefs.getString("flutter.activeKey", "");
                    // CharSequence currentText = inputConnection.getExtractedText(new
                    // ExtractedTextRequest(), 0).text;
                    if (password == null)
                        break;
                    CharSequence currentText;
                    if (encryptBuffer)
                        currentText = editText.getText().toString();
                    else
                        currentText = inputConnection.getExtractedText(new ExtractedTextRequest(), 0).text;
                    String result = "";
                    if (!currentText.toString().isEmpty()) {
                        if (!TextUtils.isEmpty(inputConnection.getSelectedText(0)))
                            inputConnection.commitText("", 1);
                        inputConnection.deleteSurroundingText(Integer.MAX_VALUE, Integer.MAX_VALUE);
                        try {
                            result = cryptoController.encrypt(currentText.toString(), password);
                        } catch (Exception e) {
                        }
                    } else {
                        ClipboardManager clipboardManager;
                        clipboardManager = (ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);
                        ClipData pData = clipboardManager.getPrimaryClip();
                        ClipData.Item item = pData.getItemAt(0);
                        String encryptedText = item.getText().toString();
                        try {
                            result = cryptoController.decrypt(encryptedText, password);
                        } catch (Exception e) {
                        }
                    }
                    editText.setText("");
                    // inputConnection.commitText(password + ' ',1);
                    inputConnection.commitText(result, 1);

                    break;

                case -7: // change to number
                    keyboard = new Keyboard(this, R.xml.keys_layout2);
                    state = Mode.NUMERIC;
                    keyboard.setShifted(caps);
                    keyboardView.setKeyboard(keyboard);
                    // keyboardView.invalidateAllKeys();
                    view.invalidate();
                    break;

                case -8: // change to symbol
                    keyboard = new Keyboard(this, R.xml.keys_layout3);
                    state = Mode.SYMBOL;
                    keyboard.setShifted(caps);
                    keyboardView.setKeyboard(keyboard);
                    // keyboardView.invalidateAllKeys();
                    view.invalidate();
                    break;

                case -9: // change to alpha
                    keyboard = new Keyboard(this, R.xml.keys_layout);
                    state = Mode.TEXT;
                    keyboard.setShifted(caps);
                    keyboardView.setKeyboard(keyboard);
                    // keyboardView.invalidateAllKeys();
                    view.invalidate();
                    break;

                case 32:
                    // difference=System.currentTimeMillis() - startTime;
                    // if(difference>700)
                    // {
                    // InputMethodManager imeManager = (InputMethodManager)
                    // getApplicationContext().getSystemService(INPUT_METHOD_SERVICE);
                    // imeManager.showInputMethodPicker();
                    // }
                    break;
                default:
                    char code = (char) primaryCode;
                    if (Character.isLetter(code) && caps) {
                        code = Character.toUpperCase(code);
                    }
                    // inputConnection.commitText(String.valueOf(code));
                    if (encryptBuffer)
                        bufferIC.commitText(String.valueOf(code), 1);
                    else
                        inputConnection.commitText(String.valueOf(code), 1);

            }
        }

    }

    @Override
    public void swipeUp() {

    }

    @Override
    public void swipeDown() {

    }

    @Override
    public void swipeLeft() {

    }

    @Override
    public void swipeRight() {

    }

    @Override
    public void onText(CharSequence c) {

    }

    public static void setTimer(int i, boolean enabled) {
        timerValue = i*1000;
        timerState = enabled;
        deleteKeyCounter = new CountDownTimer(timerValue, 1000) {

            public void onTick(long millisUntilFinished) {
            }
    
            public void onFinish() {
                deleteKey();
            }
    
        };
        deleteKeyCounter.cancel();
        deleteKeyCounter.start();
    }

    public static void setKeyValue(String p,String a) {
        keyAlias = a;
        password = p;
        deleteKeyCounter.cancel();
        deleteKeyCounter.start();
    }
}