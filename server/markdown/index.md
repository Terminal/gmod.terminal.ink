# MSS

## API

`POST /api/eval`

Evaluate JavaScript on the server

`GET /api/bans`

Get a JSON encoded list of banned people

`GET /api/points`

Get a JSON encoded list of points and items from the Pointshop

## Licence

```
MIT License

Copyright (c) 2018 Moustacheminer Server Services

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Dependencies

### System

- Node.JS
- NPM
- RethinkDB

### Node.js
```
"dependencies": {
    "body-parser": "^1.17.2",
    "config": "^1.26.1",
    "cookie-parser": "^1.4.3",
    "express": "^4.15.3",
    "express-session": "^1.15.5",
    "i18n": "^0.8.3",
    "marked": "^0.3.9",
    "passport": "^0.4.0",
    "passport-steam": "^1.0.8",
    "pug": "^2.0.0-rc.4",
    "rethinkdbdash": "^2.3.31"
}
```
