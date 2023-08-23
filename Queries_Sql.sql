--Find the 5 oldest users
  SELECT *
  FROM users
  ORDER BY created_at
  LIMIT 5;

--What day of the week do most users register on? We need to figure out when to schedule an ad campaign
  SELECT
    DAYNAME(created_at) AS DAY,
    COUNT(*) AS total
  FROM users
  GROUP BY DAY
  ORDER BY total DESC
  LIMIT 1;

--We want to target our inactive users with an email campaign. We can find users who have never posted a photo.
  SELECT
    username
  FROM users u
  LEFT JOIN photos p ON u.id = p.user_id
  WHERE p.id IS NULL;

--We're running a new contest to see who can get the most likes on a single photo. WHO WON?
  SELECT
    users.username,
    photos.id,
    photos.image_url,
    COUNT(*) AS Total_Likes
FROM likes
JOIN photos ON photos.id = likes.photo_id
JOIN users ON users.id = likes.user_id
GROUP BY photos.id
ORDER BY Total_Likes DESC
LIMIT 1;

--Our Investors want to know...How many times does the average user post? (total number of photos/total number of users)
SELECT
    ROUND((SELECT COUNT(*) FROM photos) /(SELECT COUNT(*) FROM users),2) AS AVG;

--User ranking by postings higher to lower
SELECT
    username,
    COUNT(p.image_url) AS c
FROM users u
JOIN photos p ON u.id = p.user_id
GROUP BY p.user_id
ORDER BY c DESC;
    
--Total Posts by users (more extended version of SELECT COUNT(*)FROM photos)
SELECT
    SUM(X.c)
FROM
    (SELECT
       COUNT(photos.image_url) AS c
     FROM users
     JOIN photos ON users.id = photos.user_id
     GROUP BY users.id
    ) AS X;

--Total number of users who have posted at least one time
SELECT
    COUNT(DISTINCT(users.id)) AS total
FROM users
JOIN photos ON users.id = photos.user_id;

--A brand wants to know which hashtags to use in a post. What are the top 5 most commonly used hashtags?
SELECT
    tag_name,
    COUNT(photo_tags.tag_id) AS c
FROM photo_tags
JOIN tags ON tags.id = photo_tags.tag_id
GROUP BY tags.id
ORDER BY c DESC;
    
--We have a small problem with bots on our site. Find users who have liked every single photo on the site
SELECT
    users.id,
    username,
    COUNT(users.id) AS t
FROM users
JOIN likes ON users.id = likes.user_id
GROUP BY users.id
HAVING t =(SELECT COUNT(*)FROM photos);

--We also have a problem with celebrities. Find users who have never commented on a photo
SELECT
    username,
    comment_text
FROM users u
LEFT JOIN comments c ON u.id = c.user_id
WHERE c.id IS NULL;

--Are we overrun with bots and celebrity accounts? Find the percentage of our users who have either never commented on a photo or have commented on every photo
SELECT
    nocomments.t_nocomments AS 'No comment',
    (nocomments.t_nocomments /(SELECT COUNT(*) FROM users) ) * 100 AS '%',
    allcomments.t_allcomments AS 'All comment',
    (allcomments.t_allcomments /(SELECT COUNT(*) FROM users)) * 100 AS '%'
FROM
    (SELECT COUNT(*) AS t_nocomments
     FROM (SELECT
            username,
            comment_text
           FROM users
           LEFT JOIN comments ON users.id = comments.user_id
           GROUP BY users.id
           HAVING comments.comment_text IS NULL
          ) AS total_nocomments
    ) AS nocomments
JOIN (SELECT COUNT(*) AS t_allcomments
      FROM(SELECT
              users.id,
              username,
            COUNT(users.id) AS total_comments
            FROM users
            JOIN comments ON users.id = comments.user_id
            GROUP BY users.id
            HAVING total_comments =(SELECT COUNT(*) FROM photos)
          ) AS total_allcomments
      ) AS allcomments;

--Find users who have ever commented on a photo
SELECT
    username,
    comment_text
FROM users
LEFT JOIN comments ON users.id = comments.user_id
GROUP BY users.id
HAVING comment_text IS NOT NULL;

--Are we overrun with bots and celebrity accounts? Finding the percentage of our users who have either never commented on a photo or have commented on photos before.
SELECT
    nocomments.t_nocomments AS 'No comment',
    (nocomments.t_nocomments /(SELECT COUNT(*) FROM users)) * 100 AS '%',
    allcomments.t_allcomments AS 'Atleast once comment',
    (allcomments.t_allcomments /(SELECT COUNT(*) FROM users)) * 100 AS '%'
FROM
    (SELECT
        COUNT(*) AS t_nocomments
      FROM( SELECT
              username,
              comment_text
            FROM users
            LEFT JOIN comments ON users.id = comments.user_id
            GROUP BY users.id
            HAVING comments.comment_text IS NULL
          ) AS total_nocomments
    ) AS nocomments
JOIN(SELECT 
        COUNT(*) AS t_allcomments
     FROM(SELECT
              username,
              comment_text
          FROM users
          LEFT JOIN comments ON users.id = comments.user_id
          GROUP BY users.id
          HAVING comments.comment_text IS NOT NULL
          ) AS total_allcomments
    ) AS allcomments;
