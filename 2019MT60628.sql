--1--

SELECT People.playerid, People.nameFirst as firstname, People.nameLast as lastname, SUM(Batting.CS) as total_caught_stealing FROM
People JOIN Batting ON People.playerid = Batting.playerid
WHERE Batting.CS IS NOT NULL
GROUP BY People.playerid, firstname, lastname
ORDER BY total_caught_stealing DESC, firstname ASC, lastname ASC, playerid ASC
LIMIT 10;

--2--

SELECT People.playerid, People.nameFirst as firstname, 2 * SUM(h2b) + 3 * SUM(h3b) + 4 * SUM(hr) as runscore FROM
People JOIN Batting ON People.playerid = Batting.playerid
WHERE h2b IS NOT NULL AND h3b IS NOT NULL AND hr IS NOT NULL
GROUP BY People.playerid, firstname
ORDER BY runscore DESC, firstname DESC, People.playerid ASC
LIMIT 10;

--3--

SELECT People.playerid, People.nameFirst as firstname, People.nameLast as lastname, SUM(AwardsSharePlayers.pointsWon) as total_points FROM
People JOIN AwardsSharePlayers ON People.playerid = AwardsSharePlayers.playerid
WHERE AwardsSharePlayers.yearID >= 2000
GROUP BY People.playerid, firstname, lastname
ORDER BY total_points DESC, playerid ASC;

--4--

SELECT T.playerid, T.firstname, T.lastname, AVG(seasonly_ba) as career_batting_average FROM
(SELECT People.playerid, Batting.yearid, People.nameFirst as firstname, People.nameLast as lastname, SUM(Batting.h * 1.0) / SUM(Batting.ab * 1.0) as seasonly_ba
FROM People JOIN Batting ON People.playerid = Batting.playerid
WHERE Batting.h IS NOT NULL AND Batting.ab IS NOT NULL AND Batting.ab <> 0
GROUP BY People.playerid, Batting.yearid, firstname, lastname) as T
GROUP BY T.playerid, T.firstname, T.lastname
HAVING COUNT(DISTINCT T.yearid) >= 10
ORDER BY career_batting_average DESC, playerid ASC, firstname ASC, lastname ASC
LIMIT 10;

--5--

SELECT People.playerid, People.nameFirst as firstname, People.nameLast as lastname, to_date(to_char(birthyear, '9999') || to_char(birthmonth, '9999') || to_char(birthday, '9999'), 'YYYY MM DD') as date_of_birth, COUNT(DISTINCT T.yearid) as num_seasons FROM
People JOIN
(SELECT People.playerid, Batting.yearid FROM People JOIN Batting ON People.playerid = Batting.playerid
UNION 
SELECT People.playerid, Pitching.yearid FROM People JOIN Pitching ON People.playerid = Pitching.playerid
UNION 
SELECT People.playerid, Fielding.yearid FROM People JOIN Fielding ON People.playerid = Fielding.playerid
) as T ON People.playerid = T.playerid
GROUP BY People.playerid, firstname, lastname, date_of_birth
ORDER BY num_seasons DESC, playerid ASC, firstname ASC, lastname ASC, date_of_birth ASC;

--6--

SELECT Teams.teamid, Teams.name as teamname, TeamsFranchises.franchName as franchisename, MAX(Teams.W) as num_wins FROM
Teams JOIN TeamsFranchises ON Teams.franchid = TeamsFranchises.franchid
WHERE Teams.DivWin = TRUE
GROUP BY Teams.teamid, teamname, franchisename
ORDER BY num_wins DESC, Teams.teamid ASC, teamname ASC, franchisename ASC;

--7--

SELECT T.teamid, Teams.name as teamname, Teams.yearid as seasonid, (Teams.W * 1.0 / Teams.G) * 100 as winning_percentage FROM Teams JOIN
(SELECT Teams.teamid, MAX((Teams.W * 1.0 / Teams.G) * 100) as winning_percentage FROM
Teams GROUP BY teamid HAVING SUM(Teams.W) >= 20) as T ON T.teamid = Teams.teamid AND T.winning_percentage = (Teams.W * 1.0 / Teams.G) * 100
ORDER BY winning_percentage DESC, teamid ASC, teamname ASC, seasonid ASC
LIMIT 5;

--8--

WITH Max_Salary(teamid, yearid, salary) as (
SELECT teamid, yearid, MAX(salary) FROM Salaries
GROUP BY teamid, yearid
), latest_name as (
SELECT Teams.teamid, S.teamname, Teams.yearid FROM Teams JOIN
(SELECT DISTINCT Teams.teamid, Teams.name as teamname FROM Teams JOIN 
(SELECT teamid, MAX(yearid) as latest_seasonid FROM Teams GROUP BY teamid) as T ON Teams.teamid = T.teamid AND Teams.yearid = T.latest_seasonid) as S ON S.teamid = Teams.teamid
)
SELECT latest_name.teamid, latest_name.teamname, T.yearid as seasonid, T.playerid, T.nameFirst as player_firstname, T.nameLast as player_lastname, T.salary as salary 
FROM latest_name JOIN (SELECT S.teamid, S.yearid, S.salary, S.playerid, People.nameFirst, People.nameLast FROM People JOIN (SELECT Salaries.teamid, Salaries.yearid, Salaries.salary, Salaries.playerid FROM Salaries JOIN Max_Salary ON (Salaries.teamid = Max_Salary.teamid AND Salaries.yearid = Max_Salary.yearid AND Salaries.salary = Max_Salary.salary)) as S ON People.playerid = S.playerid) as T ON latest_name.teamid = T.teamid AND latest_name.yearid = T.yearid
ORDER BY latest_name.teamid ASC, teamname ASC, seasonid ASC, T.playerid ASC, player_firstname ASC, player_lastname ASC, T.salary DESC;

--9--

WITH batter_avg_salary(b_sal) AS (SELECT SUM(Salaries.salary) / COUNT(*) FROM Salaries JOIN (SELECT DISTINCT Batting.playerid FROM Batting) as bat ON 
Salaries.playerid = bat.playerid), 
pitcher_avg_salary(p_sal) AS (SELECT SUM(Salaries.salary) / COUNT(*) FROM Salaries JOIN (SELECT DISTINCT Pitching.playerid FROM Pitching) as pitch ON
Salaries.playerid = pitch.playerid)
SELECT
CASE
	WHEN b_sal > p_sal THEN 'batsman'
	ELSE 'pitcher'
END AS player_category, 
CASE
	WHEN b_sal > p_sal THEN b_sal
	ELSE p_sal
END AS avg_salary
FROM batter_avg_salary, pitcher_avg_salary;

--10--

SELECT People.playerid, People.nameFirst as firstname, People.nameLast as lastname, COUNT(T.playerid) as number_of_batchmates FROM People JOIN (SELECT cp.playerid, cp.schoolid, cp.yearid FROM CollegePlaying as cp JOIN CollegePlaying AS cp1 ON cp.schoolid = cp1.schoolid AND cp.yearid = cp1.yearid) as T ON
People.playerid = T.playerid GROUP BY People.playerid, firstname, lastname
ORDER BY number_of_batchmates DESC, playerid ASC;

--11--

SELECT Teams.teamid, Teams.name as teamname, COUNT(*) as total_WS_wins FROM Teams WHERE Teams.WSWin = TRUE AND Teams.G >= 110
GROUP BY teamid, teamname
ORDER BY total_WS_wins DESC, teamid ASC, teamname ASC
LIMIT 5;

--12--

SELECT Pitching.playerid, People.nameFirst as firstname, People.nameLast as lastname, SUM(SV) as career_saves, COUNT(DISTINCT Pitching.yearid) as num_seasons FROM Pitching JOIN People ON Pitching.playerid = People.playerid
WHERE SV IS NOT NULL
GROUP BY Pitching.playerid, firstname, lastname
HAVING COUNT(DISTINCT Pitching.yearid) >= 15
ORDER BY career_saves DESC, num_seasons DESC, Pitching.playerid ASC, firstname ASC, lastname ASC
LIMIT 10; 

--13--

WITH pitchers AS (
SELECT p.playerid FROM Pitching as p GROUP BY p.playerid HAVING COUNT(DISTINCT p.teamid) >= 5
), T0 AS (
SELECT DISTINCT pitchers.playerid, Pitching.teamid FROM pitchers JOIN Pitching ON pitchers.playerid = Pitching.playerid
), T1 AS (
SELECT DISTINCT Pitching.playerid, Pitching.teamid, MIN(Pitching.yearid) as earliest_year FROM Pitching GROUP BY Pitching.playerid, Pitching.teamid
), T2 AS (
SELECT T1.playerid, T1.teamid, T1.earliest_year, Pitching.stint FROM T1 JOIN Pitching ON T1.playerid = Pitching.playerid AND T1.teamid = Pitching.teamid
AND T1.earliest_year = Pitching.yearid
), T3 AS (
SELECT pitchers.playerid, T2.teamid, DENSE_RANK() OVER(PARTITION BY pitchers.playerid ORDER BY T2.earliest_year ASC, T2.stint ASC) AS play_order FROM
pitchers JOIN T2 ON pitchers.playerid = T2.playerid
), T4 AS (
SELECT T3.playerid, T3.teamid, T3.play_order FROM T3 WHERE T3.play_order = 1 OR T3.play_order = 2
), latest_name as (
SELECT DISTINCT Teams.teamid, Teams.name as teamname FROM Teams JOIN 
(SELECT teamid, MAX(yearid) as latest_seasonid FROM Teams GROUP BY teamid) as T ON Teams.teamid = T.teamid AND Teams.yearid = T.latest_seasonid
), S as (
SELECT T.playerid, T.firstname, T.lastname, T.birthcity, T.birthstate, T.birthcountry, latest_name.teamname, T.play_order FROM latest_name JOIN
(SELECT T4.playerid, People.namefirst as firstname, People.namelast as lastname, People.birthcity, People.birthstate, People.birthcountry, T4.teamid, T4.play_order
FROM People JOIN T4 ON T4.playerid = People.playerid) as T ON T.teamid = latest_name.teamid
) 
SELECT S1.playerid, S1.firstname, S1.lastname, S1.birthcity, S1.birthstate, S1.birthcountry, S1.teamname as first_teamname, S2.teamname as second_teamname FROM
S as S1 JOIN S as S2 ON S1.playerid = S2.playerid AND S1.play_order = 1 AND S2.play_order = 2
ORDER BY playerid ASC, firstname ASC, lastname ASC, birthcity ASC, birthstate ASC, birthcountry ASC, first_teamname, second_teamname;

--14--

BEGIN TRANSACTION;

INSERT INTO People(playerid, nameFirst, nameLast) VALUES ('dunphil02', 'Phil', 'Dunphy');
INSERT INTO People(playerid, nameFirst, nameLast) VALUES ('tuckcam01', 'Cameron', 'Tucker');
INSERT INTO People(playerid, nameFirst, nameLast) VALUES ('scottm02', 'Michael', 'Scott');
INSERT INTO People(playerid, nameFirst, nameLast) VALUES ('waltjoe', 'Joe', 'Walt');

INSERT INTO AwardsPlayers VALUES ('dunphil02', 'Best Baseman', 2014, '', TRUE, NULL);
INSERT INTO AwardsPlayers VALUES ('tuckcam01', 'Best Baseman', 2014, '', TRUE, NULL);
INSERT INTO AwardsPlayers VALUES ('scottm02', 'ALCS MVP', 2015, 'AA', FALSE, NULL);
INSERT INTO AwardsPlayers VALUES ('waltjoe', 'Triple Crown', 2016, '', NULL, NULL);
INSERT INTO AwardsPlayers VALUES ('adamswi01', 'Gold Glove', 2017, '', FALSE, NULL);
INSERT INTO AwardsPlayers VALUES ('yostne01', 'ALCS MVP', 2017, '', NULL, NULL);

END TRANSACTION;

SELECT P.awardid, People.playerid, People.nameFirst as firstname, People.nameLast as lastname, P.num_wins FROM People JOIN
(SELECT U.awardid, MIN(U.playerid) as playerid, U.num_wins FROM
(SELECT T.awardid, T.playerid, T.num_wins FROM People JOIN
(SELECT S.awardid, S.playerid, S.num_wins, 
MAX(S.num_wins) OVER(PARTITION BY S.awardid) AS max_num_wins FROM
(SELECT ap.awardid, ap.playerid, COUNT(*) AS num_wins FROM AwardsPlayers AS ap
GROUP BY ap.awardid, ap.playerid) AS S) AS T ON T.playerid = People.playerid
WHERE T.num_wins >= max_num_wins) as U GROUP BY U.awardid, U.num_wins) as P ON P.playerid = People.playerid
ORDER BY awardid ASC, num_wins DESC, firstname ASC, lastname ASC;


--15--
SELECT M.teamid, M.teamname, M.yearid as seasonid, M.managerid, People.nameFirst as managerfirstname, People.nameLast as managerlastname FROM People JOIN
(SELECT T.managerid, T.yearid, T.teamid, Teams.name as teamname FROM Teams JOIN 
(SELECT managers.playerid as managerid, managers.yearid, managers.teamid FROM managers
WHERE (managers.inseason = 0 OR managers.inseason = 1) AND managers.yearid >= 2000 AND managers.yearid <= 2010) as T
ON Teams.teamid = T.teamid AND Teams.yearid = T.yearid) as M ON M.managerid = People.playerid
ORDER BY teamid ASC, teamname ASC, seasonid DESC, managerid ASC, managerfirstname ASC, managerlastname ASC;
--16--
WITH last_school AS (
SELECT cp.playerid, MAX(cp.yearid) AS last_school_year FROM CollegePlaying AS cp
GROUP BY cp.playerid
), total_awards AS
(SELECT ap.playerid, COUNT(*) as total_awards FROM AwardsPlayers as ap
GROUP BY ap.playerid)
SELECT T.playerid, T.schoolname as colleges_name, total_awards.total_awards FROM total_awards JOIN
(SELECT S.playerid, Schools.schoolName FROM Schools JOIN
(SELECT cp.playerid, cp.schoolid FROM CollegePlaying as cp JOIN last_school ON
cp.playerid = last_school.playerid AND cp.yearid = last_school.last_school_year) as S ON
Schools.schoolid = S.schoolid) as T ON total_awards.playerid = T.playerid
ORDER BY total_awards DESC, colleges_name ASC, playerid ASC
LIMIT 10;
--17--

WITH AwardWinners AS
(SELECT DISTINCT ap.playerid FROM AwardsPlayers AS ap
INTERSECT
SELECT DISTINCT am.playerid FROM AwardsManagers as am),
firstawards_players_year AS
(SELECT AwardWinners.playerid, MIN(AwardsPlayers.yearid) as yearid FROM AwardWinners JOIN AwardsPlayers ON AwardsPlayers.playerid = AwardWinners.playerid
GROUP BY AwardWinners.playerid),
firstawards_managers_year AS
(SELECT AwardWinners.playerid, MIN(AwardsManagers.yearid) as yearid FROM AwardWinners JOIN AwardsManagers ON AwardsManagers.playerid = AwardWinners.playerid
GROUP BY AwardWinners.playerid),
firstawards_players AS
(SELECT AwardsPlayers.playerid, MIN(AwardsPlayers.awardid) as awardid, AwardsPlayers.yearid FROM AwardsPlayers JOIN firstawards_players_year ON
firstawards_players_year.playerid = AwardsPlayers.playerid AND firstawards_players_year.yearid = AwardsPlayers.yearid
GROUP BY AwardsPlayers.playerid, AwardsPlayers.yearid),
firstawards_managers AS
(SELECT AwardsManagers.playerid, MIN(AwardsManagers.awardid) as awardid, AwardsManagers.yearid FROM AwardsManagers JOIN firstawards_managers_year ON
firstawards_managers_year.playerid = AwardsManagers.playerid AND firstawards_managers_year.yearid = AwardsManagers.yearid
GROUP BY AwardsManagers.playerid, AwardsManagers.yearid)
SELECT People.playerid, People.namefirst as firstname, People.namelast as lastname, T.playerawardid, T.playerawardyear, T.managerawardid, T.managerawardyear FROM People JOIN
(SELECT firstawards_players.playerid, firstawards_players.awardid as playerawardid, firstawards_players.yearid as playerawardyear, firstawards_managers.awardid as managerawardid, firstawards_managers.yearid as managerawardyear
FROM firstawards_players JOIN firstawards_managers ON firstawards_players.playerid = firstawards_managers.playerid) as T
ON People.playerid = T.playerid
ORDER BY playerid ASC, firstname ASC, lastname ASC, playerawardid ASC, managerawardid ASC;


--18--

WITH hof_players AS 
(SELECT hof.playerid, COUNT(DISTINCT hof.category) as num_category FROM HallOfFame AS hof
GROUP BY hof.playerid
HAVING COUNT(DISTINCT hof.category) >= 2), 
as_players AS
(SELECT asp.playerid, MIN(asp.yearid) as first_seasonid FROM AllstarFull AS asp WHERE asp.GP = 1
GROUP BY asp.playerid)
SELECT People.playerid, People.namefirst as firstname, People.namelast as lastname, T.num_category as num_honored_categories,
T.first_seasonid as seasonid FROM People JOIN (SELECT hof_players.playerid, hof_players.num_category, as_players.first_seasonid FROM
hof_players JOIN as_players ON hof_players.playerid = as_players.playerid) as T ON People.playerid = T.playerid
ORDER BY num_honored_categories DESC, playerid ASC, firstname ASC, lastname ASC, seasonid ASC;

--19--

SELECT People.playerid, People.namefirst as firstname, People.namelast as lastname, T.G_all, T.G_1b, T.G_2b, T.G_3b FROM People JOIN
(SELECT a.playerid, SUM(a.G_all) as G_all, SUM(a.G_1b) as G_1b, SUM(a.G_2b) as G_2b, SUM(a.G_3b) as G_3b
FROM Appearances as a GROUP BY a.playerid
HAVING SUM(a.G_1b) >= 1 AND SUM(a.G_2b) >= 1 OR SUM(a.G_2b) >= 1 AND SUM(a.G_3b) >= 1 OR SUM(a.G_1b) >= 1 AND SUM(a.G_3b) >= 1) as T
ON People.playerid = T.playerid
ORDER BY G_all DESC, playerid ASC, firstname ASC, lastname ASC, G_1b DESC, G_2b DESC, G_3b DESC;

--20--

WITH top_schools AS
(SELECT cp.schoolid, COUNT(DISTINCT cp.playerid) as num_players FROM CollegePlaying as cp GROUP BY cp.schoolid
ORDER BY num_players DESC LIMIT 5)
SELECT T.schoolid, T.schoolname, T.schoolcity, T.schoolstate, People.playerid, People.namefirst as firstname, People.namelast as lastname FROM People JOIN
(SELECT Schools.schoolid, Schools.schoolname, Schools.schoolcity, Schools.schoolstate, S.playerid FROM Schools JOIN
(SELECT DISTINCT cp.playerid, cp.schoolid FROM CollegePlaying as cp JOIN top_schools ON top_schools.schoolid = cp.schoolid) as S
ON S.schoolid = Schools.schoolid) as T ON People.playerid = T.playerid
ORDER BY schoolid ASC, schoolname ASC, schoolcity ASC, schoolstate ASC, playerid ASC, firstname ASC, lastname ASC;

--21--

WITH same_birthaddr AS (
SELECT p1.playerid as player1_id, p2.playerid as player2_id, p1.birthcity, p1.birthstate FROM People as p1 JOIN People as p2 ON (p1.birthcity IS NOT NULL AND p2.birthcity IS NOT NULL AND p1.birthstate IS NOT NULL AND
p2.birthstate IS NOT NULL AND p1.birthcity = p2.birthcity AND p1.birthstate = p2.birthstate AND p1.playerid != p2.playerid)),
batting_distinct_team AS (
SELECT DISTINCT Batting.playerid, Batting.teamid FROM Batting
),
bat_same_team AS (
SELECT b1.playerid as player1_id, b2.playerid as player2_id FROM batting_distinct_team as b1 JOIN batting_distinct_team as b2 ON (b1.playerid != b2.playerid AND b1.teamid = b2.teamid)
),
pitch_distinct_team AS (
SELECT DISTINCT Pitching.playerid, Pitching.teamid FROM Pitching
),
pitch_same_team AS (
SELECT p1.playerid as player1_id, p2.playerid as player2_id FROM pitch_distinct_team as p1 JOIN pitch_distinct_team as p2 ON (p1.playerid != p2.playerid AND p1.teamid = p2.teamid)
)
SELECT sb.player1_id, sb.player2_id, sb.birthcity, sb.birthstate, 'batted' as role FROM same_birthaddr as sb JOIN (SELECT * FROM bat_same_team EXCEPT SELECT * FROM pitch_same_team) as bs ON (sb.player1_id = bs.player1_id AND sb.player2_id = bs.player2_id)
UNION
SELECT sb.player1_id, sb.player2_id, sb.birthcity, sb.birthstate, 'pitched' as role FROM same_birthaddr as sb JOIN (SELECT * FROM pitch_same_team EXCEPT SELECT * FROM bat_same_team) as ps ON (sb.player1_id = ps.player1_id AND sb.player2_id = ps.player2_id)
UNION
SELECT sb.player1_id, sb.player2_id, sb.birthcity, sb.birthstate, 'both' as role FROM same_birthaddr as sb JOIN (SELECT * FROM bat_same_team INTERSECT SELECT * FROM pitch_same_team) as b ON (sb.player1_id = b.player1_id AND sb.player2_id = b.player2_id)
ORDER BY birthcity ASC, birthstate ASC, player1_id ASC, player2_id ASC;

--22--

WITH avg_award_points AS (
SELECT asp.awardid, asp.yearid, AVG(asp.pointswon) as avg_points FROM AwardsSharePlayers as asp GROUP BY asp.awardid, asp.yearid
)
SELECT aap.awardid, aap.yearid as seasonid, asp.playerid, asp.pointswon as playerpoints, aap.avg_points FROM AwardsSharePlayers as asp JOIN avg_award_points as aap 
ON asp.awardid = aap.awardid AND asp.yearid = aap.yearid AND asp.pointswon >= aap.avg_points
ORDER BY awardid ASC, seasonid ASC, playerpoints DESC, playerid ASC;

--23--

WITH award_winners AS (
SELECT DISTINCT ap.playerid FROM AwardsPlayers as ap
UNION
SELECT DISTINCT am.playerid FROM AwardsManagers as am
)
SELECT People.playerid, People.namefirst as firstname, People.namelast as lastname, 
CASE 
	WHEN People.deathday IS NULL THEN TRUE
	ELSE FALSE
END as alive
FROM People WHERE People.playerid NOT IN (SELECT * FROM award_winners)
ORDER BY playerid ASC, firstname ASC, lastname ASC;

--24--

WITH RECURSIVE paths(playerid, weight, path) AS (
SELECT edges.player2_id, edges.weight, ARRAY[edges.player1_id::text, edges.player2_id::text] FROM edges WHERE edges.player1_id = 'webbbr01'
UNION ALL
SELECT edges.player2_id, (paths.weight + edges.weight), paths.path || ARRAY[edges.player2_id::text] FROM paths JOIN edges ON paths.playerid = edges.player1_id AND  edges.player2_id != ALL(paths.path)
), edges AS 
(SELECT T.player1_id, T.player2_id, SUM(T.weight) as weight FROM
(SELECT p1.playerid as player1_id, p2.playerid as player2_id, COUNT(*) as weight FROM Pitching as p1 JOIN Pitching as p2 ON p1.teamid = p2.teamid AND p1.yearid = p2.yearid AND p1.playerid != p2.playerid
GROUP BY player1_id, player2_id
UNION
SELECT asf1.playerid as player1_id, asf2.playerid as player2_id, COUNT(*) as weight FROM AllstarFull as asf1 JOIN AllstarFull as asf2 ON asf1.teamid = asf2.teamid AND asf1.yearid = asf2.yearid AND asf1.playerid != asf2.playerid AND asf1.gp = 1 AND asf2.gp = 1
GROUP BY player1_id, player2_id) as T
GROUP BY player1_id, player2_id)
SELECT CASE 
WHEN EXISTS (SELECT * FROM paths WHERE paths.playerid = 'clemero02' AND paths.weight >= 3) THEN TRUE
ELSE FALSE 
END as pathexists;

--25--

WITH Recursive paths(playerid, weight, path) AS (
SELECT edges.player2_id, edges.weight, ARRAY[edges.player1_id::text, edges.player2_id::text] FROM edges WHERE edges.player1_id = 'garcifr02'
UNION ALL
SELECT edges.player2_id, (paths.weight + edges.weight), paths.path || ARRAY[edges.player2_id::text] FROM paths JOIN edges ON paths.playerid = edges.player1_id AND edges.player2_id != ALL(paths.path)
), edges AS
(SELECT T.player1_id, T.player2_id, SUM(T.weight) as weight FROM
(SELECT p1.playerid as player1_id, p2.playerid as player2_id, COUNT(*) as weight FROM Pitching as p1 JOIN Pitching as p2 ON p1.teamid = p2.teamid AND p1.yearid = p2.yearid AND p1.playerid != p2.playerid
GROUP BY player1_id, player2_id
UNION
SELECT asf1.playerid as player1_id, asf2.playerid as player2_id, COUNT(*) as weight FROM AllstarFull as asf1 JOIN AllstarFull as asf2 ON asf1.teamid = asf2.teamid AND asf1.yearid = asf2.yearid AND asf1.playerid != asf2.playerid AND asf1.gp = 1 AND asf2.gp = 1
GROUP BY player1_id, player2_id) as T
GROUP BY player1_id, player2_id)
SELECT CASE 
WHEN EXISTS (SELECT * FROM paths WHERE paths.playerid = 'leagubr01') THEN MIN(T.weight)
ELSE 0
END as pathlength FROM
(SELECT paths.weight FROM paths WHERE paths.playerid = 'leagubr01') AS T;

-- 26 --

WITH RECURSIVE paths(dest, path) AS (
SELECT edges.loser, ARRAY[edges.winner || edges.loser] FROM edges WHERE edges.winner = 'ARI'
UNION ALL
SELECT edges.loser, paths.path || ARRAY[edges.winner || edges.loser] FROM paths JOIN edges ON paths.dest = edges.winner AND edges.winner || edges.loser != ALL(paths.path)
), 
edges AS (
SELECT sp.teamidwinner as winner, sp.teamidloser as loser FROM SeriesPost as sp
)
SELECT COUNT(paths.path) as count FROM paths WHERE paths.dest = 'DET';

--27--

WITH RECURSIVE paths(dest, path, num_hops) AS (
SELECT edges.loser, ARRAY[edges.winner || edges.loser], CAST(1 as bigint) FROM edges WHERE edges.winner = 'HOU'
UNION ALL
SELECT edges.loser, paths.path || ARRAY[edges.winner || edges.loser], num_hops + 1 FROM paths JOIN edges ON paths.dest = edges.winner AND edges.winner || edges.loser != ALL(paths.path) AND num_hops <= 2
), 
edges AS (
SELECT sp.teamidwinner as winner, sp.teamidloser as loser FROM SeriesPost as sp
)
SELECT paths.dest as teamid, MAX(paths.num_hops) as num_hops FROM paths GROUP BY paths.dest
ORDER BY teamid;

--28--

WITH RECURSIVE paths(dest, path, len) AS (
SELECT edges.loser, ARRAY[edges.winner || edges.loser], CAST(1 as bigint) FROM edges WHERE edges.winner = 'WS1'
UNION ALL
SELECT edges.loser, paths.path || ARRAY[edges.winner || edges.loser], paths.len + 1 FROM paths JOIN edges ON paths.dest = edges.winner AND edges.winner || edges.loser != ALL(paths.path)
), 
edges AS (
SELECT sp.teamidwinner as winner, sp.teamidloser as loser FROM SeriesPost as sp
), longest_paths AS (
SELECT paths.dest, MAX(paths.len) as pathlength FROM paths GROUP BY paths.dest
),
latest_name as (
SELECT Teams.teamid, S.teamname, Teams.yearid FROM Teams JOIN
(SELECT DISTINCT Teams.teamid, Teams.name as teamname FROM Teams JOIN 
(SELECT teamid, MAX(yearid) as latest_seasonid FROM Teams GROUP BY teamid) as T ON Teams.teamid = T.teamid AND Teams.yearid = T.latest_seasonid) as S ON S.teamid = Teams.teamid
)
SELECT DISTINCT longest_paths.dest as teamid, latest_name.teamname, longest_paths.pathlength FROM latest_name JOIN longest_paths ON latest_name.teamid = longest_paths.dest
ORDER BY teamid ASC, teamname ASC;







