require 'sinatra/base'
require 'sinatra/namespace'
require './app/controllers/dokter_controller'

class DokterRoutes < Sinatra::Base
  register Sinatra::Namespace

  namespace '/dokters' do
    # List all dokters
    get '' do
      json DokterController.index
    end

    # Show specific dokter
    get '/:id' do
      dokter = DokterController.show(params[:id])
      halt 404, json(message: 'Dokter not found') unless dokter
      json dokter
    end

    # Create a new dokter
    post '' do
      new_dokter = DokterController.create(params)
      halt 400, json(message: 'Invalid data') unless new_dokter
      json new_dokter
    end

    # Update dokter
    put '/:id' do
      updated_dokter = DokterController.update(params[:id], params)
      halt 404, json(message: 'Dokter not found') unless updated_dokter
      json updated_dokter
    end

    # Delete dokter
    delete '/:id' do
      deleted_dokter = DokterController.delete(params[:id])
      halt 404, json(message: 'Dokter not found') unless deleted_dokter
      json message: 'Dokter deleted successfully'
    end
  end
end
