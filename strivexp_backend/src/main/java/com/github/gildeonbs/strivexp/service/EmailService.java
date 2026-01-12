package com.github.gildeonbs.strivexp.service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${app.email.from}")
    private String fromEmail;

    @Async // Run in background so the API response is fast
    public void sendPasswordResetEmail(String to, String resetLink) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject("StriveXP: Reset Your Password");

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

            helper.setText(htmlContent, true); // true = HTML

            mailSender.send(message);
            log.info("Password reset email sent to {}", to); // Log success, NOT the token
        } catch (MessagingException e) {
            log.error("Failed to send password reset email", e);
        }
    }
}