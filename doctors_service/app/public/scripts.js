// Fetch doctors from API and populate the table
function fetchDoctors() {
    fetch('/doctors')
        .then(response => response.json())
        .then(data => {
            const doctorsTable = document.querySelector('#doctors-table tbody');
            doctorsTable.innerHTML = ''; // Clear existing data

            data.forEach((doctor, index) => {
                const row = `
                    <tr>
                        <td>${index + 1}</td>
                        <td>${doctor.name}</td>
                        <td>${doctor.specialization}</td>
                        <td>${doctor.phone}</td>
                        <td>${doctor.work_since}</td>
                        <td>${new Date(doctor.created_at).toLocaleString()}</td>
                        <td>${new Date(doctor.updated_at).toLocaleString()}</td>
                        <td>
                            <div class="action-buttons">
                                <button class="btn btn-edit" onclick="editDoctor(${doctor.id})">Edit</button>
                                <button class="btn btn-delete" onclick="deleteDoctor(${doctor.id})">Hapus</button>
                            </div>
                        </td>
                    </tr>
                `;
                doctorsTable.innerHTML += row;
            });
        })
        .catch(error => {
            console.error('Error fetching doctors:', error);
        });
}

// Handle editing a doctor
function editDoctor(doctorId) {
    // Fetch the doctor's data
    fetch(`/doctors/${doctorId}`)
        .then(response => response.json())
        .then(doctor => {
            // Populate the form with the doctor's data
            document.getElementById('doctor-name').value = doctor.name;
            document.getElementById('doctor-specialization').value = doctor.specialization;
            document.getElementById('doctor-phone').value = doctor.phone;
            document.getElementById('doctor-work-since').value = doctor.work_since;

            // Modify the form to handle update
            const doctorForm = document.getElementById('doctor-form');
            doctorForm.dataset.editing = doctorId; // Add a data attribute to track editing
        })
        .catch(error => {
            console.error('Error fetching doctor details:', error);
        });
}

// Handle form submission for adding or editing a doctor
const doctorForm = document.getElementById('doctor-form');
doctorForm.addEventListener('submit', function (event) {
    event.preventDefault();

    const name = document.getElementById('doctor-name').value;
    const specialization = document.getElementById('doctor-specialization').value;
    const phone = document.getElementById('doctor-phone').value;
    const workSince = document.getElementById('doctor-work-since').value;

    const doctorData = {
        name: name,
        specialization: specialization,
        phone: phone,
        work_since: parseInt(workSince),
    };

    const isEditing = doctorForm.dataset.editing;

    if (isEditing) {
        // Update existing doctor
        fetch(`/doctors/${isEditing}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(doctorData),
        })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('Dokter berhasil diperbarui');
                    doctorForm.reset();
                    delete doctorForm.dataset.editing; // Clear editing state
                    fetchDoctors(); // Refresh the table
                } else {
                    alert('Gagal memperbarui dokter');
                }
            })
            .catch(error => {
                console.error('Error updating doctor:', error);
            });
    } else {
        // Add new doctor
        fetch('/doctors', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(doctorData),
        })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    doctorForm.reset();
                    fetchDoctors(); // Refresh the table
                } else {
                    alert('Error adding doctor');
                }
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }
});

// Handle deleting a doctor
function deleteDoctor(doctorId) {
    if (confirm('Apakah Anda yakin ingin menghapus dokter ini?')) {
        fetch(`/doctors/${doctorId}`, {
            method: 'DELETE',
        })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('Dokter berhasil dihapus');
                    fetchDoctors(); // Refresh the table
                } else {
                    alert('Gagal menghapus dokter');
                }
            })
            .catch(error => {
                console.error('Error deleting doctor:', error);
            });
    }
}

// Initial fetch of doctors when the page loads
document.addEventListener('DOMContentLoaded', function () {
    fetchDoctors();
});
