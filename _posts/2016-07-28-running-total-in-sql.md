---
date: "2016-07-28 01:02:59"
layout: post
title: "Running Total in SQL"
excerpt: ""
cover_image: false
comments: true
---

Recently, my Data Analytics team had to produce a cumulative downloads and revenue report for every mobile app in
every store, starting from the apps' launch dates. Even though it is very easy to finish this task using any data
analytics framework in Python or other languages, we wanted to try it in MySQL and see if it is feasible. As it
turned out, calculating cumulative summary in MySQL (or any other SQL system) is possible, yet challenging and fun.

Let's cut the chase, here is the sample structure of our database table named `app_daily`:

| app_name    | store       | country | start_date | downloads | revenue |
|-------------|-------------|---------|------------|-----------|---------|
| Hello World | App Store   | VN      | 2016-01-01 | 10        | 16.5    |
| Lorem Ipsum | Google Play | US      | 2016-01-01 | 9         | 22.67   |
| Donor       | Amazon      | UK      | 2016-01-01 | 1         | 0       |
| Hello World | App Store   | US      | 2016-01-02 | 19        | 31.35   |
| Lorem Ipsum | Google Play | UK      | 2016-01-02 | 12        | 30.23   |
| Donor       | Amazon      | VN      | 2016-01-02 | 18        | 53.82   |

The question here — again — is:

> Find the cumulative downloads and revenue of every app, in every store, starting from launch date (the first date
the app appeared). We don't need to care about the country.

Here is the expected result which we want to have:

| store       | app_name    | start_date | cumulative_downloads | cumulative_revenue |
|-------------|-------------|------------|----------------------|--------------------|
| Amazon      | Donor       | 2016-01-01 | 1                    | 0                  |
| Amazon      | Donor       | 2016-01-02 | 19                   | 53.82              |
| App Store   | Hello World | 2016-01-01 | 10                   | 16.5               |
| App Store   | Hello World | 2016-01-02 | 29                   | 47.85              |
| Google Play | Lorem Ipsum | 2016-01-01 | 9                    | 22.67              |
| Google Play | Lorem Ipsum | 2016-01-02 | 21                   | 52.90              |


## How to do it in pure SQL?

SQL has many ways to calculate cumulative summary. We will utilize View and Correlated query in our case:

```sql
-- Creates a custom View as a shortcut for our initial query
create or replace view ad as (
    select
        store,
        app_name,
        start_date,
        sum(downloads) as downloads,
        sum(revenue) as revenue
    from app_daily
    group by store, app_name, start_date
);

-- Calculates Cumulative summary
select t.store,
    t.app_name,
    t.start_date,

    (
        select sum(x.downloads)
        from ad x
        where x.start_date <= t.start_date
        and x.app_name = t.app_name
        and x.store = t.store
    ) as cumulative_downloads,

    (
        select sum(x.revenue)
        from ad x
        where x.start_date <= t.start_date
        and x.app_name = t.app_name
        and x.store = t.store
    ) as cumulative_revenue

from ad t

order by store, app_name, start_date;
```

**Pros:**

- Portable in every SQL system.

**Cons:**

- Have to create a View. May need to clean up that View when everything is done.
- Have to do correlated query twice.
- Take a long time to run if the table is very big because each correlated query had to calculate again and again.


## How to do it in MySQL?

MySQL has a very powerful variable system. This query below will make good use of that.

```sql
select ad.store,
    ad.app_name,
    ad.start_date,

    -- Checks if the current row is still for the same app and store
    -- If not, resets the cumulative_sum
    @downloads_total := if(
        @prev_app = ad.app_name and @prev_store = ad.store,
        @downloads_total,
        0
    ) + ad.downloads as cumulative_downloads,
    @revenue_total := if(
        @prev_app = ad.app_name and @prev_store = ad.store,
        @revenue_total,
        0
    ) + ad.revenue as cumulative_revenue,

    -- Assigns the previous app and store again.
    @prev_app := ad.app_name,
    @prev_store := ad.store

from (
    select app_name,
        store,
        start_date,
        sum(downloads) as downloads,
        sum(revenue) as revenue

    from app_daily
    group by app_name, store, start_date
) ad

join (
    select @prev_app := '',
        @prev_store := '',
        @downloads_total := 0,
        @revenue_total := 0
) vars

order by store, app_name, start_date;
```

**Pros**:

- Faster than the pure SQL way, because we can reuse the variables' values and don't have to recalculate
every time like how the correlated query did.

    In our production table which has 2,981,651 rows — at the writing time — the running time is 2.87 times
    faster than the pure SQL method.

- Only one query to do the trick.

**Cons**:

- Only applicable in MySQL. Incompatible with other SQL systems.
- Have two extra columns which need to be deleted after having the resulting table.
