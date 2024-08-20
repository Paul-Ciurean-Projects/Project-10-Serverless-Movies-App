document.addEventListener('DOMContentLoaded', fetchAvailableMovies);

function fetchAvailableMovies() {
    fetch('UPDATE API GOES HERE')  // <-- UPDATE API GOES ON THIS LINE
        .then(response => response.json())
        .then(data => {
            // Log the data to see the structure
            console.log("Fetched data:", data);
            
            // Ensure that data is an array of movie names
            const movieList = data.join(', ');
            document.getElementById('available-movies').textContent = movieList;
        })
        .catch(error => {
            console.error('Error fetching movies:', error);
            document.getElementById('available-movies').textContent = 'Error fetching available movies.';
        });
}


document.getElementById('search-btn').addEventListener('click', searchMovie);

function searchMovie() {
    const movieName = document.getElementById('movie-id-input').value;
    if (movieName) {
        fetch(`SEARCH API GOES HERE ?movieName=${movieName}`)    // <-- SEARCH API GOES ON THIS LINE
            .then(response => response.json())
            .then(data => {
                const tableBody = document.getElementById('table-body');
                tableBody.innerHTML = '';
                if (data && data.length > 0) {
                    data.forEach(movie => {
                        const row = `<tr>
                            <td>${movie.movies}</td>
                            <td>${movie.year}</td>
                            <td>${movie.time}</td>
                            <td>${movie.rating}</td>
                            <td>${movie.description}</td>
                        </tr>`;
                        tableBody.insertAdjacentHTML('beforeend', row);
                    });
                } else {
                    tableBody.innerHTML = '<tr><td colspan="5">No results found.</td></tr>';
                }
            })
            .catch(error => {
                console.error('Error fetching data:', error);
                const tableBody = document.getElementById('table-body');
                tableBody.innerHTML = '<tr><td colspan="5" style="color: red;">Error fetching data. Please try again later.</td></tr>';
            });
    } else {
        alert('Please enter a Movie.');
    }
}
