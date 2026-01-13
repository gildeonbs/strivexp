package com.github.gildeonbs.strivexp.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.UUID;

@Controller
public class PasswordResetPageController {

    @GetMapping("/reset-password")
    public String resetPasswordPage(
            @RequestParam UUID id,
            @RequestParam String token,
            Model model
    ) {
        model.addAttribute("tokenId", id);
        model.addAttribute("token", token);
        return "reset-password";
    }
}
