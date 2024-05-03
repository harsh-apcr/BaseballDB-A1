BEGIN TRANSACTION;

COPY People FROM '/home/postgres/col362a1/database/People.csv' WITH CSV HEADER DELIMITER AS ',';
COPY TeamsFranchises FROM '/home/postgres/col362a1/database/TeamsFranchises.csv' WITH CSV HEADER DELIMITER AS ',';
COPY Teams FROM '/home/postgres/col362a1/database/Teams.csv' WITH CSV HEADER DELIMITER AS ',';
COPY Batting FROM '/home/postgres/col362a1/database/Batting.csv' WITH CSV HEADER DELIMITER AS ',';
COPY Fielding FROM '/home/postgres/col362a1/database/Fielding.csv' WITH CSV HEADER DELIMITER AS ',';
COPY Pitching FROM '/home/postgres/col362a1/database/Pitching.csv' WITH CSV HEADER DELIMITER AS ',';
COPY AllstarFull FROM '/home/postgres/col362a1/database/AllstarFull.csv' WITH CSV HEADER DELIMITER AS ',';
COPY Appearances FROM '/home/postgres/col362a1/database/Appearances.csv' WITH CSV HEADER DELIMITER AS ',';
COPY AwardsManagers FROM '/home/postgres/col362a1/database/AwardsManagers.csv' WITH CSV HEADER DELIMITER AS ',';
COPY AwardsPlayers FROM '/home/postgres/col362a1/database/AwardsPlayers.csv' WITH CSV HEADER DELIMITER AS ',';
COPY AwardsShareManagers FROM '/home/postgres/col362a1/database/AwardsShareManagers.csv' WITH CSV HEADER DELIMITER AS ',';
COPY AwardsSharePlayers FROM '/home/postgres/col362a1/database/AwardsSharePlayers.csv' WITH CSV HEADER DELIMITER AS ',';
COPY HallOfFame FROM '/home/postgres/col362a1/database/HallOfFame.csv' WITH CSV HEADER DELIMITER AS ',';
COPY Managers FROM '/home/postgres/col362a1/database/Managers.csv' WITH CSV HEADER DELIMITER AS ',';
COPY Salaries FROM '/home/postgres/col362a1/database/Salaries.csv' WITH CSV HEADER DELIMITER AS ',';
COPY Schools FROM '/home/postgres/col362a1/database/Schools.csv' WITH CSV HEADER DELIMITER AS ',';
COPY CollegePlaying FROM '/home/postgres/col362a1/database/CollegePlaying.csv' WITH CSV HEADER DELIMITER AS ',';
COPY SeriesPost FROM '/home/postgres/col362a1/database/SeriesPost.csv' WITH CSV HEADER DELIMITER AS ',';

END TRANSACTION;

