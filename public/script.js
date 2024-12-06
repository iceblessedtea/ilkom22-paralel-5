// Fungsi untuk mengonfirmasi penghapusan rekam medis
function confirmDelete(recordId) {
    const confirmation = confirm("Apakah Anda yakin ingin menghapus rekam medis ini?");
    if (confirmation) {
      // Logika untuk penghapusan (misalnya mengirim permintaan DELETE ke server)
      alert("Rekam medis dengan ID " + recordId + " telah dihapus.");
    }
  }
  
  // Validasi form pada halaman tambah rekam medis
  document.addEventListener("DOMContentLoaded", function() {
    const form = document.querySelector('form');
    const idInput = document.querySelector('#id');
    const nameInput = document.querySelector('#patient_name');
    const diagnosisInput = document.querySelector('#diagnosis');
  
    form.addEventListener('submit', function(event) {
      if (!idInput.value || !nameInput.value || !diagnosisInput.value) {
        event.preventDefault(); // Cegah form submit jika ada field yang kosong
        alert('Semua kolom harus diisi.');
      }
    });
  });
  