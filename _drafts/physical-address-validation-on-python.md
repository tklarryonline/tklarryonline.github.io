---
layout: post
title: "Physical address validation on Python"
excerpt: "A small war between EasyPost and SmartyStreets"
cover_image: false
comments: true
---

Recently I and my pair had to implement a physical address validation functionality on our Python project at East Agile. We started off with [USPS Web Tool APIs](https://www.usps.com/business/web-tools-apis/welcome.htm) per client request, however their complicated registration process and slow customer supportation stopped us to go any further. In the search to overcome this hassle, we fortunately passed by two promising APIs: [*EasyPost*](https://www.easypost.com/docs) and [*SmartyStreets*](http://smartystreets.com/kb/liveaddress-api). Our findings led to another big question:

> Which service should we choose to fulfill our need?

And I'm writing to find out which one and why. I will evaluate each of them on the following categories:

- API documentation
- API tutorial and samples
- API integration and supports for Python
- API pricing
- Detailedness and usefulness of response object

## API documentation

**EasyPost:**

EasyPost has a very well-structured and detailed documentation. 
