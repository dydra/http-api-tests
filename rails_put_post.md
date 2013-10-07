
### notes on a request's effective method

When a client - in particular a rails-generated client, performs an update request, there are circumstances
which lead it to encode the actual method elsewhere than the HTTP protocol method.[1,2]
The effective method can appear as

  - as a form field `_method` in an `x-www-form-urlencoded` body
  - a an `X-HTTP-Method-Override` header in a non-form body

As an additional wrinkle, given a body as requested by rails,

    utf8=3&_method=put&authenticity_token=XR2RR3czwS9DvgJKQhLfzNPkKo1lnVd/vTKZrHfQAhE=&repository[privacy_setting]=1&commit=Update


the rails urlencoded body would succeed

    utf8=%E2%9C%93&_method=put&authenticity_token=XR2RR3czwS9DvgJKQhLfzNPkKo1lnVd%2FvTKZrHfQAhE%3D&repository%5Bprivacy_setting%5D=1&commit=Update

the curl urlencoded body encodes additional characters

    utf8%3D%E2%9C%93%26%5Fmethod%3Dput%26authenticity%5Ftoken%3DXR2RR3czwS9DvgJKQhLfzNPkKo1lnVd%2FvTKZrHfQAhE%3D%26repository%5Bprivacy%5Fsetting%5D%3D1%26commit%3DUpdate

for which PHP fails to decode the form and the `$_POST` value is empty. This although the PHP `urldecode` operator returns the expected decoded string value.

---

[1] : http://stackoverflow.com/questions/286321/how-can-i-emulate-put-delete-for-rails-and-gwt  
[2] : http://stackoverflow.com/questions/1249282/set-method-to-put-in-rails-xml-requests
