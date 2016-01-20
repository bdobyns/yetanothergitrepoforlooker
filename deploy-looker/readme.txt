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

