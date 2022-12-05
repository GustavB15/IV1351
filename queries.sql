SELECT
DATE_TRUNC('month', lesson.start_time),
COUNT(lesson.lesson_id) as total_Lessons, 
COUNT(CASE WHEN lesson.lesson_type_id = 1 then 1 ELSE NULL END) as total_personal_lessons,
COUNT(CASE WHEN lesson.lesson_type_id = 2 then 1 ELSE NULL END) as total_group_lessons,
COUNT(CASE WHEN lesson.lesson_type_id = 3 then 1 ELSE NULL END) as total_ensembles
FROM lesson
WHERE DATE_TRUNC('year', lesson.start_time) = DATE_TRUNC('year', CURRENT_DATE)
GROUP BY DATE_TRUNC('month', lesson.start_time)
ORDER BY DATE_TRUNC('month', lesson.start_time);

SELECT siblings3.total_siblings, COUNT(*)
FROM (
    SELECT student.student_id, COUNT(CASE WHEN siblings.student_id IS NOT NULL then 1 ELSE NULL END) as total_siblings
    FROM siblings
    RIGHT JOIN student ON (student.student_id = siblings.student_id OR student.student_id = siblings.student_sibling_id)
    GROUP BY student.student_id
    ORDER BY student.student_id
) AS siblings3
GROUP BY siblings3.total_siblings
ORDER BY siblings3.total_siblings;

SELECT lesson.instructor_id, COUNT(*) as total_lessons_given
FROM lesson
WHERE DATE_TRUNC('month', lesson.start_time) = DATE_TRUNC('month', CURRENT_DATE)
GROUP BY lesson.instructor_id
HAVING COUNT(*) > 5
ORDER BY COUNT(*) DESC;


SELECT lesson.lesson_id, to_char(lesson.start_time, 'fmDay') as day, genre.genre, 
CASE 
    WHEN 
    (lesson.maximum_participants - COUNT(*)) < 1
    THEN 'fully booked'
    WHEN
    (lesson.maximum_participants - COUNT(*)) < 3
    THEN '1 or 2 spots left'
    ELSE 'more than 2 spots left'
END AS spots_left
FROM lesson
LEFT JOIN student_lesson_xref ON lesson.lesson_id = student_lesson_xref.lesson_id
LEFT JOIN genre ON lesson.genre_id = genre.genre_id
GROUP BY lesson.lesson_id, genre.genre_id
HAVING lesson.lesson_type_id = 3 AND lesson.start_time BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 DAYS'
ORDER BY lesson.start_time, genre.genre_id;