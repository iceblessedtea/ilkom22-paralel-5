require 'sinatra'
require 'sinatra/reloader' if development?  # Reload otomatis di mode development
require 'json'

# Simulasi database rekam medis
records = []

# Atur folder untuk file statis (CSS, JS)
set :public_folder, 'public'
set :views, 'views'

# Halaman utama: daftar rekam medis
get '/' do
  @records = records
  erb :index
end

# Halaman untuk menambahkan rekam medis baru
get '/new' do
  erb :new_record
end

# Proses menambahkan rekam medis baru
post '/medical_records' do
  record = {
    id: params[:id],
    patient_name: params[:patient_name],
    diagnosis: params[:diagnosis]
  }

  if record[:id].empty? || record[:patient_name].empty? || record[:diagnosis].empty?
    @error = "Semua kolom harus diisi!"
    erb :new_record
  else
    records << record
    redirect '/'
  end
end
