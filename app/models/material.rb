class Material < ApplicationRecord
  FUNCTIONS = [
    "conductive", "dielectric", "soldermask", "stiffener", "final_finish", "peelable_mask",
  ]
  GROUPS = [
    "FR1",
    "FR2",
    "FR3",
    "FR4",
    "FR5",
    "G-10",
    "G-11",
    "CEM-1",
    "CEM-2",
    "CEM-3",
    "CEM-4",
    "CEM-5",
    "ceramic",
    "polyimide",
    "aramid",
    "acrylic",
    "LCP",
    "PEN",
    "PET",
    "LPISM",
    "DFISM",
    "LDISM",
    "stainless_steel",
    "copper",
    "aluminum",
    "silver",
    "gold",
    "carbon",
    "silver_platinum",
    "silver_paladium",
    "gold_platinum",
    "platinum",
    "c_bare_copper",
    "isn",
    "iag",
    "enig",
    "enepig",
    "osp",
    "ht_osp",
    "g",
    "GS",
    "t_fused",
    "tlu_unfused",
    "dig",
    "gwb-1_ultrasonic",
    "gwb-2-thermosonic",
    "s_hasl",
    "b1_lfhasl",
    "IMS",
    "PTFE/None",
    "PTFE/Ceramic",
    "Hydrocarbon/None",
    "Hydrocarbon/Ceramic",
  ]
  UL = ["v-0", "v-1", "hb"]
  FOIL_ROUGHNESS = ["L", "S", "V"]
  IPC_840 = ["T", "H", "TF", "HF"]
  FINISH = ["matte", "glossy", "semi_glossy"]
  UNITS = {
    circuitdata_material_db_id: nil,
    name: nil,
    manufacturer: nil,
    function: nil,
    group: nil,
    foil_roughness: nil,
    cti: nil,
    electric_strength: nil,
    finish: nil,
    flexible: nil,
    ipc_slash_sheet: nil,
    ipc_sm_840_class: nil,
    ipc_standard: nil,
    link: nil,
    ul94: nil,
    verified: nil,

    tg_min: "°C",
    td_min: "°C",
    t260: "min",
    t280: "min",
    t300: "min",
    mot: "°C",
    z_cte: "%",
    z_cte_before_tg: "ppm/°C",
    z_cte_after_tg: "ppm/°C",
    dielectric_breakdown: "kV",
    water_absorption: "%",
    thermal_conductivity: "W/mK",
    # Not units but this is the easiest way to get it into the CSV.
    dk: "@ 1GHz",
    df: "@ 1GHz",
  }

  NUMERICAL_COLUMN_TYPES = [:decimal, :integer]

  belongs_to :manufacturer, optional: true

  validates :name, presence: true
  validates :function, inclusion: { in: FUNCTIONS }
  validates :group, inclusion: { in: GROUPS }, allow_nil: true
  validates :ul_94, inclusion: { in: UL }, allow_nil: true
  validates :foil_roughness, inclusion: { in: FOIL_ROUGHNESS }, allow_nil: true
  validates :ipc_sm_840_class, inclusion: { in: IPC_840 }, allow_nil: true
  validates :finish, inclusion: { in: FINISH }, allow_nil: true
  validates :link, http_uri: true, if: -> { link.present? }

  before_validation :normalize_blank_values

  delegate :name, to: :manufacturer, prefix: true, allow_nil: true

  scope :with_manufacturer, -> { where.not(manufacturer_id: nil) }
  scope :generic, -> { where(manufacturer_id: nil) }

  def datasheet
    @datasheet ||= Datasheet.new(self)
  end

  def self.numerical_columns
    columns.select { |c| NUMERICAL_COLUMN_TYPES.include?(c.type) }
      .map(&:name).sort
  end

  def self.material_function
    FUNCTIONS.map { |name| [name.humanize(capitalize: true), name] }
  end

  private

  def normalize_blank_values
    attributes.each do |column, value|
      if value.is_a?(String) && value.blank?
        self[column] = nil
      end
    end
  end
end
