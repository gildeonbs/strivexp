package com.github.gildeonbs.strivexp.service;

import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.services.gmail.Gmail;
import com.google.api.services.gmail.model.Message;
import com.google.auth.http.HttpCredentialsAdapter;
import com.google.auth.oauth2.UserCredentials;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.codec.binary.Base64;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.security.GeneralSecurityException;
import java.util.Properties;

@Service
@Slf4j
public class EmailService {

    @Value("${google.client.id}")
    private String clientId;

    @Value("${google.client.secret}")
    private String clientSecret;

    @Value("${google.refresh.token}")
    private String refreshToken;

    @Value("${google.user.email}")
    private String fromEmail;

    private Gmail gmailService;

    @PostConstruct
    public void init() {
        // Validate credentials before attempting to build
        if (clientId == null || clientId.isEmpty() || clientId.contains("${")) {
            log.error("Google Client ID is missing or invalid. Check application.properties.");
            return; // Skip initialization to avoid crash, but email won't work
        }
        if (clientSecret == null || clientSecret.isEmpty() || clientSecret.contains("${")) {
            log.error("Google Client Secret is missing.");
            return;
        }
        if (refreshToken == null || refreshToken.isEmpty() || refreshToken.contains("${")) {
            log.error("Google Refresh Token is missing.");
            return;
        }

        try {
            // 1. Build Credentials using the Refresh Token
            UserCredentials credentials = UserCredentials.newBuilder()
                    .setClientId(clientId)
                    .setClientSecret(clientSecret)
                    .setRefreshToken(refreshToken)
                    .build();

            // 2. Initialize the Gmail Service once
            this.gmailService = new Gmail.Builder(
                    GoogleNetHttpTransport.newTrustedTransport(),
                    GsonFactory.getDefaultInstance(),
                    new HttpCredentialsAdapter(credentials))
                    .setApplicationName("StriveXP")
                    .build();

            log.info("Gmail Service initialized successfully for {}", fromEmail);
        } catch (GeneralSecurityException | IOException e) {
            log.error("Failed to initialize Gmail Service", e);
            // We do NOT throw RuntimeException here to prevent app crash on startup
            // if email config is bad.
        }
    }

    public void sendVerificationEmail(String to, String verificationLink) {
        if (gmailService == null) {
            log.error("Cannot send email: Gmail Service not initialized.");
            return;
        }
        String subject = "StriveXP: Verify your email";
        String htmlContent = """
            <html>
            <body>
                <h2>Welcome to StriveXP!</h2>
                <p>Please verify your email address to secure your account and enable future logins.</p>
                <p><a href="%s">Click here to Verify Email</a></p>
                <p>This link expires in 24 hours.</p>
            </body>
            </html>
            """.formatted(verificationLink);

        sendEmail(to, subject, htmlContent);
    }

    public void sendPasswordResetEmail(String to, String resetLink) {
        if (gmailService == null) {
            log.error("Cannot send email: Gmail Service not initialized.");
            return;
        }
        String subject = "StriveXP: Reset Your Password";
        String htmlContent = """
            <html>
            <body>
                <h2>Password Reset Request</h2>
                <p>We received a request to reset your password for StriveXP.</p>
                <p>Click the link below to set a new password. This link is valid for 15 minutes.</p>
                <a href="%s">Reset Password</a>
                <p>If you did not request this, please ignore this email.</p>
            </body>
            </html>
            """.formatted(resetLink);

        sendEmail(to, subject, htmlContent);
    }

    private void sendEmail(String toEmail, String subject, String bodyText) {
        try {
            // 3. Create the Email Content (MIME)
            Properties props = new Properties();
            Session session = Session.getDefaultInstance(props, null);
            MimeMessage email = new MimeMessage(session);

            email.setFrom(new InternetAddress(fromEmail));
            email.addRecipient(javax.mail.Message.RecipientType.TO, new InternetAddress(toEmail));
            email.setSubject(subject);
            email.setContent(bodyText, "text/html; charset=utf-8");

            // 4. Encode and Send
            ByteArrayOutputStream buffer = new ByteArrayOutputStream();
            email.writeTo(buffer);
            byte[] bytes = buffer.toByteArray();
            String encodedEmail = Base64.encodeBase64URLSafeString(bytes);

            Message message = new Message();
            message.setRaw(encodedEmail);

            gmailService.users().messages().send("me", message).execute();
            log.info("Email sent successfully to {}", toEmail);

        } catch (MessagingException | IOException e) {
            log.error("Failed to send email to {} via Gmail API", toEmail, e);
        }
    }
}