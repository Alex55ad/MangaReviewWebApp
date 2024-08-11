package com.utcn.manga_review.controller;

import com.utcn.manga_review.entity.User;
import com.utcn.manga_review.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RequestMapping("/users")
@RestController
@CrossOrigin
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;
    @GetMapping("/getAll")
    public List<User> retrieveAllUsers(){
        return userService.retrieveUsers();
    }

    @PostMapping("/insert")
    public User insertUser(@RequestBody User user){
        return userService.insertUser(user);
    }

    @DeleteMapping("/deleteById")
    public void deleteUserById(@RequestParam Long id){
        userService.deleteUserById(id);
    }

    @PostMapping("/login")
    public ResponseEntity<?> loginUser(@RequestParam String username, @RequestParam String password){
        User user = userService.loginUser(username, password);
        if (user != null){
            return ResponseEntity.ok(user);
        }
        else{
            return ResponseEntity.badRequest().body("Username or Password invalid");
        }
    }

    @PostMapping("/signin")
    public User createUser(@RequestBody User user){
        return userService.createUser(user);
    }


    @PutMapping("/ban")
    public User banUser(@RequestParam Long id){
        return userService.banUser(id);
    }

    @PutMapping("/unban")
    public User unbanUser(@RequestParam Long id){
        return userService.unbanUser(id);
    }

    @PutMapping("/updateScore")
    public ResponseEntity<User> updateUserAverageScore(@RequestParam Long userId) {
        try {
            User user = userService.updateUserAverageScore(userId);
            return ResponseEntity.ok(user);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
    @PutMapping("/encryptPasswords")
    public void encryptPasswords() {
        userService.encryptExistingPasswords();
    }

}
