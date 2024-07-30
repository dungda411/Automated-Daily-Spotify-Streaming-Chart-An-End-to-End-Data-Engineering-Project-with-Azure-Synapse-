--- Total Artist's Daily Stream
WITH lead_artist_name AS(
    SELECT Artist_Name, Artist_ID, Song_ID
    FROM artist_info AS ai
    JOIN lead_artist AS la
    ON ai.Artist_ID = la.Lead_Artist_ID
),
artist_song_name AS(
    SELECT Artist_Name, Song_Name, lan.Song_ID, Track_Number, Disc_Number
    FROM lead_artist_name AS lan
    JOIN song_info AS si 
    ON lan.Song_ID = si.Song_ID
),
album_song_name AS(
    SELECT Album_Name, Total_Tracks, Album_Type, Song_ID
    FROM album_info AS ali
    JOIN album_song AS als
    ON ali.Album_ID = als.Album_ID
),
album_song_artist AS (
    SELECT Album_Name, Total_Tracks, Song_Name, Track_Number, Artist_Name, Album_Type, artist_song_name.Song_ID
    FROM artist_song_name
    JOIN album_song_name
    ON artist_song_name.Song_ID = album_song_name.Song_ID
)
SELECT Album_Name, AVG(Total_Tracks) AS Total_Tracks, SUM(Stream) AS Total_Stream, Artist_Name, Album_Type
FROM album_song_artist
JOIN song_stream
ON album_song_artist.Song_ID = song_stream.Song_ID
WHERE Artist_Name = 'Adele' AND Album_Type = 'album'
GROUP BY Album_Name, Artist_Name, Album_Type, Extract_Date
ORDER BY Total_Stream DESC;
