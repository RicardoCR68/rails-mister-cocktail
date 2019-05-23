class DosesController < ApplicationController
  before_action :set_dose, only: %i[show destroy]
  before_action :set_cocktail, only: %i[index new create]

  def index
    @doses = @cocktail.doses
  end

  def new
    @dose = Dose.new
  end

  def create
    @dose = Dose.new(dose_params)
    @dose.cocktail = @cocktail

    if @dose.save
      redirect_to cocktail_path(@cocktail)
    else
      render :new
    end
  end

  def show; end

  def edit; end

  def update
    if @dose.update(dose_params)
      redirect_to dose_path
    else
      render :edit
    end
  end

  def destroy
    @dose.destroy

    redirect_to cocktail_path
  end

  private

  def set_dose
    @dose = Dose.find(params[:id])
  end

  def set_cocktail
    @cocktail = Cocktail.find(params[:cocktail_id])
  end

  def dose_params
    params.require(:dose).permit(:description, :ingredient_id)
  end
end
