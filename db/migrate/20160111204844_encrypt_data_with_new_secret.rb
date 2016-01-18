class EncryptDataWithNewSecret < ActiveRecord::Migration
  def up
    Rake::Task['reencrypt:all_data'].invoke('l&]{l8=Y>b+f}&5Ku2[`6~jX4)Q6-xx,85&E]~+*?}V&rR91q[QCgxgvgD\PfUhJ.tVzm4znz!Hk?|aazas`c42GAjRItl}BkIa9>\89_S[=Uvm6TE"F4;VFVVcS}{/Y[6p8`Xj}A)%]F6m')
  end

  def down
  end
end
