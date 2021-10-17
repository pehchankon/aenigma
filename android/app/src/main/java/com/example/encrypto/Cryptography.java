package com.example.encrypto;
import java.security.*;
import javax.crypto.*;

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
import android.view.KeyEvent;
import android.view.View;
import android.view.inputmethod.InputConnection;
import android.content.SharedPreferences;
import android.content.Context;
import androidx.annotation.RequiresApi;

import android.app.Activity;

public class Cryptography
{


    @RequiresApi(api = Build.VERSION_CODES.O)
    public String decrypt (String outputString,String password) throws Exception {
        SecretKeySpec key = generateKey(password);
        Cipher c = Cipher.getInstance("AES");
        c.init(Cipher.DECRYPT_MODE, key);

        byte[] decodedValue = Base64.getDecoder().decode(outputString);
        byte[] decValue = c.doFinal(decodedValue);

        String decryptedValue = new String(decValue);
        return decryptedValue;

    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    public String encrypt (String Data,String password) throws Exception {
        SecretKeySpec key = generateKey(password);
        Cipher c = Cipher.getInstance("AES");

        c.init(Cipher.ENCRYPT_MODE, key);

        byte[] encVal = c.doFinal(Data.getBytes());

        String encryptedValue = Base64.getEncoder().encodeToString(encVal);
        return encryptedValue;
    }
    private SecretKeySpec generateKey(String password) throws Exception
    {
        final MessageDigest digest = MessageDigest.getInstance("SHA-256");
        byte[] bytes = password.getBytes("UTF-8");
        digest.update (bytes, 0, bytes.length);
        byte [] key = digest.digest();
        SecretKeySpec secretKeySpec = new SecretKeySpec(key, "ARS");
        return secretKeySpec;
    }
}