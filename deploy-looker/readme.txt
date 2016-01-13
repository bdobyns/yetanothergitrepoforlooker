                                                                                                                                                                                                                                                               
Delivered-To: barry@productops.com
Received: by 10.202.63.193 with SMTP id m184csp3025536oia;
        Tue, 12 Jan 2016 15:01:17 -0800 (PST)
X-Received: by 10.60.124.83 with SMTP id mg19mr28249895oeb.14.1452639677456;
        Tue, 12 Jan 2016 15:01:17 -0800 (PST)
Return-Path: <will.bartee@productops.com>
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id 62si7130411oid.142.2016.01.12.15.01.17
        for <barry@productops.com>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 15:01:17 -0800 (PST)
Received-SPF: pass (google.com: domain of will.bartee@productops.com designates 2607:f8b0:4003:c06::22f as permitted sender) client-ip=2607:f8b0:4003:c06::22f;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of will.bartee@productops.com designates 2607:f8b0:4003:c06::22f as permitted sender) smtp.mailfrom=will.bartee@productops.com;
       dkim=pass header.i=@productops-com.20150623.gappssmtp.com
Received: by mail-oi0-x22f.google.com with SMTP id o124so73926269oia.3
        for <barry@productops.com>; Tue, 12 Jan 2016 15:01:17 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=productops-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:in-reply-to:references:date:message-id:subject:from:to
         :content-type;
        bh=25XaC8ul3niXGJiBtgSHGqE4qQCiWq1CWZckHQIopfk=;
        b=VS3jtM5r55UzBbVCgSlRXpvui3oXc+/8cPcavYMxEGC0Lkd/BwSdzzBKxgAOzerDMa
         JDG2Zr2cCNMVatdOFvifwlop50yPimk0ZaMEk1aonpSeP9dl3D8GYadkuPozCwVs8Cm4
         YIbCR4FGS+298mZO/4ZQne583LyFraoqqzHIgzXrCPy2aE7BC9YVKEBA4mAQglkaHZRN
         gdLaFzQ4HQlcQdSaSPCd0Xg++u2JiYM/zMcq85XKRuKhRd9ZXFwF7wOXSsV8TxOg2KHm
         ey0eDA6p3n6vIcpPTzMYdVlPbeJGNPZM3UE4k2OznJHKsuzVGLcjIiJh2TYm3KL+NOQq
         UUfw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20130820;
        h=x-gm-message-state:mime-version:in-reply-to:references:date
         :message-id:subject:from:to:content-type;
        bh=25XaC8ul3niXGJiBtgSHGqE4qQCiWq1CWZckHQIopfk=;
        b=aZ8jAe00OY4sh3VPUvG0s/cKdjxjOhrr3YxFIfSNoeBtFNrf3spvop0WUp6nd7/tw8
         ORl6LBBVzalWUi/F6/FOVIDXspPDkZ0EyfWcxVALT45dAVpBDP3O9kythMcheHgC6OaJ
         G8P90ob649hE4490jdSgPGdYEy+XWH9MxZDQaOpPIMLNCNyRxQNIy61sONTAHZqHMq+q
         3W50Vu+r8sOUgLwjHEvsoIteWuO84ZiKRaF1s+5vh3HtDCqPHLnEIlvXw9fsXy2a1zdG
         mzMu5+4MJneIKQNr3Xtf4pDDPIJ8jc/+eStX42Frk80P3CydId5y7wRf6N5AV9NyTB0d
         O81Q==
X-Gm-Message-State: ALoCoQkZpnplax3NSr9/zn6Z8BINL8zYTbCYsYN105Etwdb0lcirTEykbiKozMSIbiaPfb0dQNWp/ef+o6NZEwXGkJvojJbUweBrLMx05wvUDUrlo1ydm+4=
MIME-Version: 1.0
X-Received: by 10.202.169.207 with SMTP id s198mr94783410oie.28.1452639676976;
 Tue, 12 Jan 2016 15:01:16 -0800 (PST)
Received: by 10.76.177.104 with HTTP; Tue, 12 Jan 2016 15:01:16 -0800 (PST)
In-Reply-To: <CAFzLN44xWGGWvbTbobe62qACfeRmhmDPVkbHW62TxfTVrs4kfg@mail.gmail.com>
References: <CAL+BRMZweUbJFFvUc=G=YdWF31Y28=htBW+smUs8+shgKzqksw@mail.gmail.com>
	<CAL+BRMaugGrHO3F4Js67tcvZDU_+i0ceCVr1WCjxW_B3qchmLg@mail.gmail.com>
	<CAPh4MStT7pDzpQjki0zUjCuPG5WMi5JxXYHtfxZtLdbUF3ENRw@mail.gmail.com>
	<CAFzLN44xWGGWvbTbobe62qACfeRmhmDPVkbHW62TxfTVrs4kfg@mail.gmail.com>
Date: Tue, 12 Jan 2016 15:01:16 -0800
Message-ID: <CAD46r1zz2_vefT_ndTEhewE1vv+_96MNHH7OvFBsxXVgw-dNXQ@mail.gmail.com>
Subject: Fwd: Ithaka & Product Ops - Looker Trial
From: Will Bartee <will.bartee@productops.com>
To: Barry Dobyns <barry@productops.com>
Content-Type: multipart/related; boundary=001a113cd9aeef24fc05292b07cb

--001a113cd9aeef24fc05292b07cb
Content-Type: multipart/alternative; boundary=001a113cd9aeef24f805292b07ca

--001a113cd9aeef24f805292b07ca
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

---------- Forwarded message ----------
From: Anika Kuesters Smith <anika@looker.com>
Date: Sun, Jan 10, 2016 at 9:05 PM
Subject: Re: Ithaka & Product Ops - Looker Trial
To: Paul Iverson <paul@productops.com>, Diego Simkin <diego@looker.com>
Cc: Will Bartee <will.bartee@productops.com>, Bob Cagle <bob@productops.com=
>


Hi All,

Thanks again for meeting with us on Thursday! I enjoyed getting you started
using Looker. Diego got approval for the on-prem license, so I wanted to
send over everything you=E2=80=99ll need to deploy Looker in Ithaka=E2=80=
=99s environment.

   - Directions
   <http://www.looker.com/docs/setup-and-management/on-prem-install>
   - License Key: 28C7-047A-BD5E-03E8-C8AE
   - Start-up script
   <https://s3.amazonaws.com/download.looker.com/aeHee2HiNeekoh3uIu6hec3W/l=
ooker>

   - Latest Jar File
   <https://s3.amazonaws.com/download.looker.com/aeHee2HiNeekoh3uIu6hec3W/l=
ooker-latest.jar>

The changes Will made look great. I pushed out a few more changes from our
session, added the adjustment to usec_timestamp that Will figured out
throughout the model, and stripped quotes from num_requested_items:

  - dimension: num_requested_items
    type: number
    sql: TRIM(BOTH '"' FROM ${TABLE}.num_requested_items)

This example should work for anything we need to drop quotes from.

Please let me know if any questions come up before our next meeting, and
don=E2=80=99t hesitate to use in-app chat!

Cheers,
Anika
=E2=80=8B

On Sun, Jan 10, 2016 at 2:04 PM Paul Iverson <paul@productops.com> wrote:

> Diego,
>
> That sounds good. How about 10 am on the 19th.
>
> Have a good week
>
> Paul
>
>
>
> On Sun, Jan 10, 2016 at 12:20 PM, Diego Simkin <diego@looker.com> wrote:
>
>> Product Ops Team,
>>
>> Great meeting with you on Thursday. We're off the a good start now that
>> we have the DB connected and a couple ideas of how we want to analyze th=
e
>> data. Also, Anika told me that you solved the date issue?! Awesome! We h=
ave
>> a couple actions on our end so expect to hear from us as the week
>> progresses. Please feel free to reach out via email if you have any
>> questions, Monday/Tuesday we'll have periodic breaks. There is our In-Ap=
p
>> chat support, they are a super knowledgeable team who are here from 6am-=
6pm
>> PST.
>>
>> Let's plan to meet the following week. Anika and I have to head up to SF
>> Monday. Do any of the below time slots work for you?
>>
>> Tuesday (1/19): 9am or 10am
>> Wednesday (1/20): 11am or 2pm
>>
>> Thanks!
>>
>>
>> [image: Inline image 1]
>> <https://t.yesware.com/tl/740df7983dc963d0d69519ea979d11ac4ed93fc0/8992b=
ef1892c9983832e7a02fc9a65ef/f0b879c233709cec3686db1999c4d4b0?ytl=3Dhttp%3A%=
2F%2Fwww.looker.com%2F>
>> *Diego Simkin *[image: www.linkedin.com/pub/diego-simkin/51/175/688/]
>> <http://www.linkedin.com/pub/diego-simkin/51/175/688/>
>> <https://www.youtube.com/user/LookerData>
>> 831-359-8021 | www.looker.com
>> <https://t.yesware.com/tl/740df7983dc963d0d69519ea979d11ac4ed93fc0/8992b=
ef1892c9983832e7a02fc9a65ef/21ee7ea396de49be59bb42fdc2bd3252?ytl=3Dhttp%3A%=
2F%2Fwww.looker.com>
>> Need More Info? -- Looker Resources!
>> <http://www.looker.com/resources#ufh>
>>
>> On Wed, Jan 6, 2016 at 4:46 PM, Diego Simkin <diego@looker.com> wrote:
>>
>>> Hi Paul and Will,
>>>
>>> Great chatting earlier today and looking forward to getting the trial
>>> started.
>>>
>>> We successfully launched ithaka.looker.com. Please prepare the database
>>> for connection per Step 1 in these instructions
>>> <http://www.looker.com/docs/admin/setup/looker-hosted> (whitelist our
>>> IPs) and add your database connection here:
>>> https://ithaka.looker.com/admin/connections/new.
>>>
>>> For tomorrow we'll start off with some reports that you think would mak=
e
>>> sense. We can build those and continue with more advanced logic as the
>>> trial progresses. Anika will be your dedicated Looker Analyst throughou=
t
>>> the entire trial.
>>>
>>> Looking forward to getting things kicked off!
>>>
>>> [image: Inline image 1]
>>> <https://t.yesware.com/tl/740df7983dc963d0d69519ea979d11ac4ed93fc0/8992=
bef1892c9983832e7a02fc9a65ef/f0b879c233709cec3686db1999c4d4b0?ytl=3Dhttp%3A=
%2F%2Fwww.looker.com%2F>
>>> *Diego Simkin *[image: www.linkedin.com/pub/diego-simkin/51/175/688/]
>>> <http://www.linkedin.com/pub/diego-simkin/51/175/688/>
>>> <https://www.youtube.com/user/LookerData>
>>> 831-359-8021 | www.looker.com
>>> <https://t.yesware.com/tl/740df7983dc963d0d69519ea979d11ac4ed93fc0/8992=
bef1892c9983832e7a02fc9a65ef/21ee7ea396de49be59bb42fdc2bd3252?ytl=3Dhttp%3A=
%2F%2Fwww.looker.com>
>>> Need More Info? -- Looker Resources!
>>> <http://www.looker.com/resources#ufh>
>>>
>>
>>
>

--001a113cd9aeef24f805292b07ca
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_quote">---------- Forwarded messag=
e ----------<br>From: <b class=3D"gmail_sendername">Anika Kuesters Smith</b=
> <span dir=3D"ltr">&lt;<a href=3D"mailto:anika@looker.com">anika@looker.co=
m</a>&gt;</span><br>Date: Sun, Jan 10, 2016 at 9:05 PM<br>Subject: Re: Itha=
ka &amp; Product Ops - Looker Trial<br>To: Paul Iverson &lt;<a href=3D"mail=
to:paul@productops.com">paul@productops.com</a>&gt;, Diego Simkin &lt;<a hr=
ef=3D"mailto:diego@looker.com">diego@looker.com</a>&gt;<br>Cc: Will Bartee =
&lt;<a href=3D"mailto:will.bartee@productops.com">will.bartee@productops.co=
m</a>&gt;, Bob Cagle &lt;<a href=3D"mailto:bob@productops.com">bob@producto=
ps.com</a>&gt;<br><br><br><div dir=3D"ltr"><div><p style=3D"margin:1.2em 0p=
x!important">Hi All,</p>
<p style=3D"margin:1.2em 0px!important">Thanks again for meeting with us on=
 Thursday! I enjoyed getting you started using Looker. Diego got approval f=
or the on-prem license, so I wanted to send over everything you=E2=80=99ll =
need to deploy Looker in Ithaka=E2=80=99s environment.</p><ul><li><a href=
=3D"http://www.looker.com/docs/setup-and-management/on-prem-install" style=
=3D"line-height:1.5" target=3D"_blank">Directions</a></li><li><span style=
=3D"line-height:1.5">License Key: 28C7-047A-BD5E-03E8-C8AE=C2=A0</span></li=
><li><a href=3D"https://s3.amazonaws.com/download.looker.com/aeHee2HiNeekoh=
3uIu6hec3W/looker" style=3D"line-height:1.5" target=3D"_blank">Start-up scr=
ipt</a><span style=3D"line-height:1.5">=C2=A0</span></li><li><a href=3D"htt=
ps://s3.amazonaws.com/download.looker.com/aeHee2HiNeekoh3uIu6hec3W/looker-l=
atest.jar" style=3D"line-height:1.5" target=3D"_blank">Latest Jar File</a><=
br></li></ul><p style=3D"margin:1.2em 0px!important">The changes Will made =
look great. I pushed out a few more changes from our session, added the adj=
ustment to <code style=3D"font-size:0.85em;font-family:Consolas,Inconsolata=
,Courier,monospace;margin:0px 0.15em;padding:0px 0.3em;white-space:pre-wrap=
;border:1px solid rgb(234,234,234);border-radius:3px;display:inline;backgro=
und-color:rgb(248,248,248)">usec_timestamp</code> that Will figured out thr=
oughout the model, and stripped quotes from <code style=3D"font-size:0.85em=
;font-family:Consolas,Inconsolata,Courier,monospace;margin:0px 0.15em;paddi=
ng:0px 0.3em;white-space:pre-wrap;border:1px solid rgb(234,234,234);border-=
radius:3px;display:inline;background-color:rgb(248,248,248)">num_requested_=
items</code>:</p>
<pre style=3D"font-size:0.85em;font-family:Consolas,Inconsolata,Courier,mon=
ospace;font-size:1em;line-height:1.2em;margin:1.2em 0px"><code style=3D"fon=
t-size:0.85em;font-family:Consolas,Inconsolata,Courier,monospace;margin:0px=
 0.15em;padding:0px 0.3em;white-space:pre-wrap;border:1px solid rgb(234,234=
,234);border-radius:3px;display:inline;background-color:rgb(248,248,248);wh=
ite-space:pre-wrap;overflow:auto;border-radius:3px;border:1px solid rgb(204=
,204,204);padding:0.5em 0.7em;display:block!important">  - dimension: num_r=
equested_items
    type: number
    sql: TRIM(BOTH &#39;&quot;&#39; FROM ${TABLE}.num_requested_items)
</code></pre><p style=3D"margin:1.2em 0px!important">This example should wo=
rk for anything we need to drop quotes from. </p>
<p style=3D"margin:1.2em 0px!important">Please let me know if any questions=
 come up before our next meeting, and don=E2=80=99t hesitate to use in-app =
chat!</p>
<p style=3D"margin:1.2em 0px!important">Cheers,<br>Anika</p>
<div title=3D"MDH:SGkgQWxsLDxkaXY+PGJyPjwvZGl2PjxkaXY+VGhhbmtzIGFnYWluIGZvc=
iBtZWV0aW5nIHdpdGgg
dXMgb24gVGh1cnNkYXkhIEkgZW5qb3llZCBnZXR0aW5nIHlvdSBzdGFydGVkIHVzaW5nIExvb2t=
l
ci4mbmJzcDs8c3BhbiBzdHlsZT0ibGluZS1oZWlnaHQ6IDEuNTsiPkRpZWdvIGdvdCBhcHByb3Z=
h
bCBmb3IgdGhlIG9uLXByZW0gbGljZW5zZSwgc28gSSB3YW50ZWQgdG8gc2VuZCBvdmVyIGV2ZXJ=
5
dGhpbmcgeW91J2xsIG5lZWQgdG8gZGVwbG95IExvb2tlciBpbiBJdGhha2EncyBlbnZpcm9ubWV=
u
dC48L3NwYW4+PC9kaXY+PGRpdj48dWw+PGxpPjxhIGhyZWY9Imh0dHA6Ly93d3cubG9va2VyLmN=
v
bS9kb2NzL3NldHVwLWFuZC1tYW5hZ2VtZW50L29uLXByZW0taW5zdGFsbCIgc3R5bGU9ImxpbmU=
t
aGVpZ2h0OiAxLjU7Ij5EaXJlY3Rpb25zPC9hPjxicj48L2xpPjxsaT48c3BhbiBzdHlsZT0ibGl=
u
ZS1oZWlnaHQ6IDEuNTsiPkxpY2Vuc2UgS2V5OiZuYnNwOzI4QzctMDQ3QS1CRDVFLTAzRTgtQzh=
B
RTwvc3Bhbj48YnI+PC9saT48bGk+PGEgaHJlZj0iaHR0cHM6Ly9zMy5hbWF6b25hd3MuY29tL2R=
v
d25sb2FkLmxvb2tlci5jb20vYWVIZWUySGlOZWVrb2gzdUl1NmhlYzNXL2xvb2tlciIgc3R5bGU=
9
ImxpbmUtaGVpZ2h0OiAxLjU7Ij5TdGFydC11cCBzY3JpcHQ8L2E+PGJyPjwvbGk+PGxpPjxhIGh=
y
ZWY9Imh0dHBzOi8vczMuYW1hem9uYXdzLmNvbS9kb3dubG9hZC5sb29rZXIuY29tL2FlSGVlMkh=
p
TmVla29oM3VJdTZoZWMzVy9sb29rZXItbGF0ZXN0LmphciI+TGF0ZXN0IEphciBGaWxlPC9hPjw=
v
bGk+PC91bD48ZGl2PlRoZSBjaGFuZ2VzIFdpbGwgbWFkZSBsb29rIGdyZWF0LiBJIHB1c2hlZCB=
v
dXQgYSBmZXcgbW9yZSBjaGFuZ2VzIGZyb20gb3VyIHNlc3Npb24sIGFkZGVkIHRoZSBhZGp1c3R=
t
ZW50IHRvIGB1c2VjX3RpbWVzdGFtcGAgdGhhdCBXaWxsIGZpZ3VyZWQgb3V0IHRocm91Z2hvdXQ=
g
dGhlIG1vZGVsLCBhbmQgc3RyaXBwZWQgcXVvdGVzIGZyb20gYG51bV9yZXF1ZXN0ZWRfaXRlbXN=
g
OjwvZGl2PjwvZGl2PjxkaXY+YGBgPC9kaXY+PGRpdj48ZGl2PiZuYnNwOyAtIGRpbWVuc2lvbjo=
g
bnVtX3JlcXVlc3RlZF9pdGVtczwvZGl2PjxkaXY+Jm5ic3A7ICZuYnNwOyB0eXBlOiBudW1iZXI=
8
L2Rpdj48ZGl2PiZuYnNwOyAmbmJzcDsgc3FsOiBUUklNKEJPVEggJyInIEZST00gJHtUQUJMRX0=
u
bnVtX3JlcXVlc3RlZF9pdGVtcyk8L2Rpdj48L2Rpdj48ZGl2PmBgYDwvZGl2PjxkaXY+VGhpcyB=
l
eGFtcGxlIHNob3VsZCB3b3JrIGZvciBhbnl0aGluZyB3ZSBuZWVkIHRvIGRyb3AgcXVvdGVzIGZ=
y
b20uJm5ic3A7PC9kaXY+PGRpdj48YnI+PC9kaXY+PGRpdj5QbGVhc2UgbGV0IG1lIGtub3cgaWY=
g
YW55IHF1ZXN0aW9ucyBjb21lIHVwIGJlZm9yZSBvdXIgbmV4dCBtZWV0aW5nLCBhbmQgZG9uJ3Q=
g
aGVzaXRhdGUgdG8gdXNlIGluLWFwcCBjaGF0ITxicj48YnI+PC9kaXY+PGRpdj5DaGVlcnMsPC9=
k
aXY+PGRpdj5BbmlrYTwvZGl2PjxkaXY+PGJyPjwvZGl2PjxkaXY+PGJyPjwvZGl2Pg=3D=3D" s=
tyle=3D"min-height:0;width:0;max-height:0;max-width:0;overflow:hidden;font-=
size:0em;padding:0;margin:0">=E2=80=8B</div></div></div><div class=3D"HOEnZ=
b"><div class=3D"h5"><br><div class=3D"gmail_quote"><div dir=3D"ltr">On Sun=
, Jan 10, 2016 at 2:04 PM Paul Iverson &lt;<a href=3D"mailto:paul@productop=
s.com" target=3D"_blank">paul@productops.com</a>&gt; wrote:<br></div><block=
quote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc=
 solid;padding-left:1ex"><div dir=3D"ltr">Diego,<div><br></div><div>That so=
unds good. How about 10 am on the 19th.</div><div><br></div><div>Have a goo=
d week</div></div><div dir=3D"ltr"><div><br></div><div>Paul</div></div><div=
 dir=3D"ltr"><div class=3D"gmail_extra"><br clear=3D"all"><div><div><div di=
r=3D"ltr"><div dir=3D"ltr"><div dir=3D"ltr"><div dir=3D"ltr"><div dir=3D"lt=
r"><div dir=3D"ltr"><div dir=3D"ltr"><div style=3D"font-size:12.8px"><br></=
div></div></div></div></div></div></div></div></div></div>
<br><div class=3D"gmail_quote">On Sun, Jan 10, 2016 at 12:20 PM, Diego Simk=
in <span dir=3D"ltr">&lt;<a href=3D"mailto:diego@looker.com" target=3D"_bla=
nk">diego@looker.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_qu=
ote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex=
"><div dir=3D"ltr"><div style=3D"color:#000000">Product Ops Team,=C2=A0</di=
v><div style=3D"color:#000000"><br></div><div style=3D"color:#000000">Great=
 meeting with you on Thursday. We&#39;re off the a good start now that we h=
ave the DB connected and a couple ideas of how we want to analyze the data.=
 Also, Anika told me that you solved the date issue?! Awesome! We have a co=
uple actions on our end so expect to hear from us as the week progresses. P=
lease feel free to reach out via email if you have any questions, Monday/Tu=
esday we&#39;ll have periodic breaks. There is our In-App chat support, the=
y are a super knowledgeable team who are here from 6am-6pm PST.=C2=A0</div>=
<div style=3D"color:#000000"><br></div><div style=3D"color:#000000">Let&#39=
;s plan to meet the following week. Anika and I have to head up to SF Monda=
y. Do any of the below time slots work for you?=C2=A0</div><div style=3D"co=
lor:#000000"><br></div><div style=3D"color:#000000">Tuesday (1/19): 9am or =
10am</div><div style=3D"color:#000000">Wednesday (1/20): 11am or 2pm=C2=A0<=
/div><div style=3D"color:#000000"><br></div><div style=3D"color:#000000">Th=
anks!=C2=A0<br>=C2=A0</div><img src=3D"http://t.yesware.com/t/39074874fb386=
9b1cde10ffc690bca8d41bb06ea/76c927fe1de72a604176993d4156d23e/spacer.gif" st=
yle=3D"border:0;width:0;min-height:0;overflow:hidden" width=3D"0" height=3D=
"0"><font face=3D"yw-39074874fb3869b1cde10ffc690bca8d41bb06ea-76c927fe1de72=
a604176993d4156d23e--tolfcu"></font><img src=3D"https://t.yesware.com/t/390=
74874fb3869b1cde10ffc690bca8d41bb06ea/76c927fe1de72a604176993d4156d23e/spac=
er.gif" style=3D"border:0;width:0;min-height:0;overflow:hidden" width=3D"0"=
 height=3D"0"><img src=3D"http://t.yesware.com/t/39074874fb3869b1cde10ffc69=
0bca8d41bb06ea/76c927fe1de72a604176993d4156d23e/spacer.gif" style=3D"border=
:0;width:0;min-height:0;overflow:hidden" width=3D"0" height=3D"0"></div><di=
v class=3D"gmail_extra"><span><br clear=3D"all"><div><div><div dir=3D"ltr">=
<div><div dir=3D"ltr"><div><div dir=3D"ltr"><div><div dir=3D"ltr"><div><div=
 dir=3D"ltr"><div style=3D"font-size:12.8000001907349px"><a href=3D"https:/=
/t.yesware.com/tl/740df7983dc963d0d69519ea979d11ac4ed93fc0/8992bef1892c9983=
832e7a02fc9a65ef/f0b879c233709cec3686db1999c4d4b0?ytl=3Dhttp%3A%2F%2Fwww.lo=
oker.com%2F" style=3D"font-family:arial;font-size:large;color:rgb(17,85,204=
)" target=3D"_blank"><img src=3D"cid:ii_1424cd558fca7e2f" alt=3D"Inline ima=
ge 1"></a><br></div><div style=3D"font-size:12.8000001907349px"><span style=
=3D"color:rgb(68,68,68);font-family:arial,helvetica,sans-serif"><font size=
=3D"2"><b>Diego Simkin=C2=A0</b><a href=3D"http://www.linkedin.com/pub/dieg=
o-simkin/51/175/688/" style=3D"color:rgb(17,85,204)" target=3D"_blank"><img=
 src=3D"https://static.licdn.com/scds/common/u/img/webpromo/btn_in_20x15.pn=
g" alt=3D"www.linkedin.com/pub/diego-simkin/51/175/688/"></a></font></span>=
<a href=3D"https://www.youtube.com/user/LookerData" target=3D"_blank"><img =
src=3D"https://docs.google.com/uc?export=3Ddownload&amp;id=3D0B8uB7hTb1xnFO=
FgwWC13NDdzczg&amp;revid=3D0B8uB7hTb1xnFeVlWN2lBbTBkVTlrT1NpUVU1TUJQaTFYblE=
wPQ" style=3D"font-size:12.8000001907349px"></a>=C2=A0</div><div style=3D"f=
ont-size:12.8000001907349px"><font size=3D"2"><a href=3D"tel:831-359-8021" =
value=3D"+18318244299" style=3D"color:rgb(17,85,204)" target=3D"_blank">831=
-359-8021</a>=C2=A0|=C2=A0<a href=3D"https://t.yesware.com/tl/740df7983dc96=
3d0d69519ea979d11ac4ed93fc0/8992bef1892c9983832e7a02fc9a65ef/21ee7ea396de49=
be59bb42fdc2bd3252?ytl=3Dhttp%3A%2F%2Fwww.looker.com" style=3D"color:rgb(17=
,85,204)" target=3D"_blank">www.looker.com</a></font></div><div style=3D"fo=
nt-size:12.8000001907349px"><a href=3D"http://www.looker.com/resources#ufh"=
 target=3D"_blank">Need More Info? -- Looker Resources! </a></div></div></d=
iv></div></div></div></div></div></div></div></div></div>
<br></span><div><div><div class=3D"gmail_quote">On Wed, Jan 6, 2016 at 4:46=
 PM, Diego Simkin <span dir=3D"ltr">&lt;<a href=3D"mailto:diego@looker.com"=
 target=3D"_blank">diego@looker.com</a>&gt;</span> wrote:<br><blockquote cl=
ass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;p=
adding-left:1ex"><div dir=3D"ltr"><div style=3D"color:rgb(0,0,0)">Hi Paul a=
nd Will,=C2=A0</div><div style=3D"color:rgb(0,0,0)"><br></div><div style=3D=
"color:rgb(0,0,0)">Great chatting earlier today and looking forward to gett=
ing the trial started.=C2=A0</div><div style=3D"color:rgb(0,0,0)"><span sty=
le=3D"font-size:12.8px;font-family:arial,helvetica,sans-serif"><br></span><=
/div><div style=3D"color:rgb(0,0,0)"><span style=3D"font-size:12.8px;font-f=
amily:arial,helvetica,sans-serif">We successfully launched=C2=A0</span><a h=
ref=3D"http://ithaka.looker.com/" style=3D"font-size:12.8px;font-family:ari=
al,helvetica,sans-serif" target=3D"_blank">ithaka.looker.com</a><span style=
=3D"font-size:12.8px;font-family:arial,helvetica,sans-serif">. Please prepa=
re the database for connection per=C2=A0</span><a href=3D"http://www.looker=
.com/docs/admin/setup/looker-hosted" style=3D"font-size:12.8px;font-family:=
arial,helvetica,sans-serif" target=3D"_blank">Step 1 in these instructions<=
/a><span style=3D"font-size:12.8px;font-family:arial,helvetica,sans-serif">=
=C2=A0(whitelist our IPs) and add your database connection here:=C2=A0</spa=
n><a href=3D"https://ithaka.looker.com/admin/connections/new" style=3D"font=
-size:12.8px;font-family:arial,helvetica,sans-serif" target=3D"_blank">http=
s://ithaka.looker.com/admin/connections/new</a>.=C2=A0</div><div style=3D"c=
olor:rgb(0,0,0)"><span style=3D"font-size:12.8px"><br></span></div><div sty=
le=3D"color:rgb(0,0,0)"><span style=3D"font-size:12.8px">For tomorrow we&#3=
9;ll start off with some reports that you think would make sense. We can bu=
ild those and continue with more advanced logic</span><img src=3D"https://t=
.yesware.com/t/39074874fb3869b1cde10ffc690bca8d41bb06ea/cde6bc0f9af03f70204=
bb0d18ae20b89/spacer.gif" width=3D"0" height=3D"0" style=3D"color:rgb(34,34=
,34);font-size:12.8px;border:0px;width:0px;min-height:0px;overflow:hidden">=
<img src=3D"http://t.yesware.com/t/39074874fb3869b1cde10ffc690bca8d41bb06ea=
/cde6bc0f9af03f70204bb0d18ae20b89/spacer.gif" width=3D"0" height=3D"0" styl=
e=3D"color:rgb(34,34,34);font-size:12.8px;border:0px;width:0px;min-height:0=
px;overflow:hidden">=C2=A0as the trial progresses. Anika will be your dedic=
ated Looker Analyst throughout the entire trial.=C2=A0<br></div><div style=
=3D"color:rgb(0,0,0)"><br></div><div style=3D"color:rgb(0,0,0)">Looking for=
ward to getting things kicked off!=C2=A0</div><div style=3D"color:rgb(0,0,0=
)">=C2=A0<br></div><div><div><div dir=3D"ltr"><div><div dir=3D"ltr"><div><d=
iv dir=3D"ltr"><div><div dir=3D"ltr"><div><div dir=3D"ltr"><div style=3D"fo=
nt-size:12.8px"><a href=3D"https://t.yesware.com/tl/740df7983dc963d0d69519e=
a979d11ac4ed93fc0/8992bef1892c9983832e7a02fc9a65ef/f0b879c233709cec3686db19=
99c4d4b0?ytl=3Dhttp%3A%2F%2Fwww.looker.com%2F" style=3D"font-family:arial;f=
ont-size:large;color:rgb(17,85,204)" target=3D"_blank"><img src=3D"cid:ii_1=
424cd558fca7e2f" alt=3D"Inline image 1"></a><br></div><div style=3D"font-si=
ze:12.8px"><span style=3D"color:rgb(68,68,68);font-family:arial,helvetica,s=
ans-serif"><font size=3D"2"><b>Diego Simkin=C2=A0</b><a href=3D"http://www.=
linkedin.com/pub/diego-simkin/51/175/688/" style=3D"color:rgb(17,85,204)" t=
arget=3D"_blank"><img src=3D"https://static.licdn.com/scds/common/u/img/web=
promo/btn_in_20x15.png" alt=3D"www.linkedin.com/pub/diego-simkin/51/175/688=
/"></a></font></span><a href=3D"https://www.youtube.com/user/LookerData" ta=
rget=3D"_blank"><img src=3D"https://docs.google.com/uc?export=3Ddownload&am=
p;id=3D0B8uB7hTb1xnFOFgwWC13NDdzczg&amp;revid=3D0B8uB7hTb1xnFeVlWN2lBbTBkVT=
lrT1NpUVU1TUJQaTFYblEwPQ" style=3D"font-size:12.8px"></a>=C2=A0</div><div s=
tyle=3D"font-size:12.8px"><font size=3D"2"><a href=3D"tel:831-359-8021" val=
ue=3D"+18318244299" style=3D"color:rgb(17,85,204)" target=3D"_blank">831-35=
9-8021</a>=C2=A0|=C2=A0<a href=3D"https://t.yesware.com/tl/740df7983dc963d0=
d69519ea979d11ac4ed93fc0/8992bef1892c9983832e7a02fc9a65ef/21ee7ea396de49be5=
9bb42fdc2bd3252?ytl=3Dhttp%3A%2F%2Fwww.looker.com" style=3D"color:rgb(17,85=
,204)" target=3D"_blank">www.looker.com</a></font></div><div style=3D"font-=
size:12.8px"><a href=3D"http://www.looker.com/resources#ufh" target=3D"_bla=
nk">Need More Info? -- Looker Resources! </a></div></div></div></div></div>=
</div></div></div></div></div></div></div>
<img src=3D"https://t.yesware.com/t/39074874fb3869b1cde10ffc690bca8d41bb06e=
a/0d9cee88bdcb32f5567828ee32bb08ef/spacer.gif" style=3D"border:0px;width:0p=
x;min-height:0px;overflow:hidden" width=3D"0" height=3D"0"><img src=3D"http=
://t.yesware.com/t/39074874fb3869b1cde10ffc690bca8d41bb06ea/0d9cee88bdcb32f=
5567828ee32bb08ef/spacer.gif" style=3D"border:0px;width:0px;min-height:0px;=
overflow:hidden" width=3D"0" height=3D"0"><font face=3D"yw-39074874fb3869b1=
cde10ffc690bca8d41bb06ea-0d9cee88bdcb32f5567828ee32bb08ef--tocb"></font></d=
iv>
</blockquote></div><br></div></div></div>
</blockquote></div><br></div></div></blockquote></div>
</div></div></div><br></div>

--001a113cd9aeef24f805292b07ca--
--001a113cd9aeef24fc05292b07cb
Content-Type: image/png; name="Looker_Logo3.png"
Content-Disposition: inline; filename="Looker_Logo3.png"
Content-Transfer-Encoding: base64
Content-ID: <ii_1424cd558fca7e2f>
X-Attachment-Id: ii_1424cd558fca7e2f

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
--001a113cd9aeef24fc05292b07cb--
