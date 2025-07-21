package com.demo.kuberdemo.Controller;


import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class OldController {

    // 👇 "old code" endpoint — leave untouched for the first commit
    @GetMapping("/old")
    public String old() {
        return "Hello from OLD code 👋";
    }

//    @GetMapping("/new")
//    public String newCommit(){
//        return "Hello from New commit code 👋";
//    }
}