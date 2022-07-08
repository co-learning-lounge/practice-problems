Visit https://colearninglounge.com/blogs/ for more indepth and hands-on learning

SELECT *
FROM yog_ai.deliveries_3 
LIMIT 5 ;

SELECT match_id, team1 as home, team2 as away, winner
FROM yog_ai.matches_3 
WHERE season = '2022' ;

-- Display the final match
SELECT max(match_id)
FROM yog_ai.matches_3 
WHERE season = '2022' and match_number is NULL;  -- is NULL, ISNULL

SELECT match_id, team1 as home, team2 as away, winner, win_by, winner_type
FROM yog_ai.matches_3 
WHERE season = '2022' and match_number is NULL
ORDER BY match_id desc 
limit 1;

SELECT match_id, team1 as home, team2 as away, winner, win_by, winner_type
FROM yog_ai.matches_3 
WHERE season = '2022' and match_number is NULL
ORDER BY start_date desc 
LIMIT 1;

-- Player of the series
-- Find the player who have won "player of the match" highest number of times 
-- 1. "player_of_match"
-- 2. Find the player with maximum occurance

SELECT max(player_of_match) as player_of_the_series
FROM yog_ai.matches_3 
WHERE season = '2021' ;

-- Find the player of the match season wise
-- 1. season, player_of_match
-- 2. Group by season and count maximum player_of_match

SELECT season, max(player_of_match) as player_of_series
FROM yog_ai.matches_3 
GROUP BY season 
ORDER BY season;

-- Find out number of times player have been awarded player of the match
-- 1. player name <-- player_of_match
-- 2. number of times <-- count
-- 3. group by player_of_match

SELECT player_of_match, count(player_of_match) as no_of_pom
FROM yog_ai.matches_3 
GROUP BY player_of_match
ORDER BY no_of_pom desc

SELECT season, player_of_match, count(player_of_match) as no_of_pom
FROM yog_ai.matches_3 
WHERE match_number is not NULL
GROUP BY player_of_match, season
HAVING season = '2020/21'
ORDER BY season desc, no_of_pom

SELECT *
FROM yog_ai.matches_3 ;

-- Get the unique values of season
SELECT DISTINCT season
FROM yog_ai.deliveries 
ORDER BY season;

SELECT DISTINCT season, match_id
FROM yog_ai.deliveries
ORDER BY season, match_id desc;

SELECT DISTINCT season, match_id
FROM yog_ai.deliveries
ORDER BY season desc, match_id;

SELECT DISTINCT season, match_id
FROM yog_ai.deliveries
ORDER BY season desc, match_id desc;

SELECT COUNT(*)
FROM yog_ai.venue_3

-- 1. filter 2022 data from matches table
-- 2. Group by winner to get total no. of wins for each team
-- 3. Order by based on wins
-- 4. Calculate the points
-- 5. Find the total matches - (10 + 18 + 8 + 14 + 12 + 8)/10 = 70/10 = 7 * 2 = 14

SELECT winner as team, (SELECT ((count(*)/count(DISTINCT winner)) * 2) as matches
                        FROM yog_ai.matches_3 
                        WHERE season = '2022' and match_number is not NULL) as matches, 
                        count(winner) as win, 
                        (14 - count(winner)) as loss, 
                        count(winner) * 2 as points
FROM yog_ai.matches_3
WHERE season = '2022' and match_number is not NULL
GROUP BY winner
ORDER BY win desc;

-- (10 + 18 + 8 + 14 + 12 + 8)/10 = 70/10 = 7 * 2 = 14

SELECT ((count(*)/count(DISTINCT winner)) * 2) as matches
FROM yog_ai.matches_3 
WHERE season = '2022' and match_number is not NULL ;

SELECT *
FROM yog_ai.matches_3
WHERE match_number is not NULL and outcome is not NULL

SELECT * -- Total - 950. Unique - 950
FROM yog_ai.matches_3 ;

SELECT *
FROM yog_ai.venue_3 ;

SELECT *  -- Total - 225954, Unique - 950
FROM yog_ai.deliveries ;

-- How many matches were lost by team batting first(won the toss) and scored more than 200 runs?
-- 1. match_id, batting_team(innings), runs(> 200), winner, toss_winner
-- 2. match_id, winner, toss_decision --> matches | innings, total_runs(runs_off_bat + extras) --> deliveries
-- 3. JOIN
-- 4. How many matches --> count, winner != batting_team, toss_decision == bat, total_runs > 200

SELECT m.match_id, max(m.winner), sum(d.runs_off_bat + d.extras) as total_runs -- d.innings, m.winner, m.toss_winner, m.toss_decision,
FROM yog_ai.deliveries d 
JOIN yog_ai.matches_3 m 
  ON d.match_id = m.match_id
WHERE m.toss_decision = 'bat' and m.winner != m.toss_winner and innings = 1
GROUP BY m.match_id
HAVING sum(d.runs_off_bat + d.extras) > 200

 -- d.innings, m.winner, m.toss_winner, m.toss_decision,
SELECT COUNT(*)
FROM (SELECT m.match_id, max(m.winner), sum(d.runs_off_bat + d.extras) as total_runs
      FROM yog_ai.deliveries d 
      JOIN yog_ai.matches_3 m 
        ON d.match_id = m.match_id
      WHERE m.toss_decision = 'bat' and m.winner != m.toss_winner and innings = 1
      GROUP BY m.match_id) a
WHERE a.total_runs > 200

SELECT m.match_id, max(m.winner), sum(d.runs_off_bat + d.extras) as total_runs
SELECT max(sum(d.runs_off_bat + d.extras)) as higest_score
FROM yog_ai.deliveries d 
JOIN yog_ai.matches_3 m 
  ON d.match_id = m.match_id
WHERE m.toss_decision = 'bat' and m.winner != m.toss_winner and innings = 1
GROUP BY m.match_id
ORDER BY total_runs desc
LIMIT 2

SELECT MAX(total_runs) as higest_score
FROM (SELECT sum(d.runs_off_bat + d.extras) as total_runs
        FROM yog_ai.deliveries d 
        JOIN yog_ai.matches_3 m 
          ON d.match_id = m.match_id
        WHERE m.toss_decision = 'bat' and m.winner != m.toss_winner and innings = 1
        GROUP BY m.match_id) a
        
-- SELECT 
-- FROM/JOIN
-- WHERE/HAVING

-- Example of subqeuery in WHERE. From here - https://learnsql.com/blog/sql-subquery-examples/
SELECT name, listed_price
FROM paintings
WHERE listed_price > (SELECT AVG(listed_price)
                      FROM paintings)

SELECT match_id,
        innings,
        team,
        match_score,
        match_score/CASE
          WHEN over >= 19.6 OR wickets = 10 THEN 20
          ELSE ((split_part(over::TEXT, '.', 1))::INT + 1.0/(split_part(over::TEXT, '.', 2)::INT))
        END AS nrr
FROM   (SELECT match_id,
               innings,
               Max(batting_team) as team,
               Max(ball)                  AS over,
               Sum(runs_off_bat + extras) AS match_score,
               Count(player_dismissed)    AS wickets
        FROM   yog_ai.deliveries
        WHERE  season = '2022'
        GROUP  BY match_id, innings
        ORDER  BY match_id, innings) a


-- What is the lowest first innings score of the tournament in ______?
-- How many runs team DC scored at Dubai in the matches they won? 
