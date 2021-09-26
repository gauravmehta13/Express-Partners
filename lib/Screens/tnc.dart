import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        centerTitle: true,
        title: Text(
          "Terms & Conditions",
          style:
              GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            box10,
            Image.asset(
              "assets/tnc.jpg",
              height: 180,
            ),
            box10,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Terms and Conditions of Business",
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10),
                itemCount: buisnessTnc.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${(index + 1).toString()} .  ",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        Expanded(
                            child: Text(
                          buisnessTnc[index],
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ))
                      ],
                    ),
                  );
                }),
            box10,
            Divider(),
            ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10),
                itemCount: otherTNC.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          otherTNC[index]["title"],
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            itemCount: otherTNC[index]["tnc"].length,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int i) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${(i + 1).toString()} .  ",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Expanded(
                                        child: Text(
                                      otherTNC[index]["tnc"][i],
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black87),
                                    ))
                                  ],
                                ),
                              );
                            }),
                        Divider(
                          color: Colors.grey,
                          height: 30,
                        )
                      ]);
                }),
            Divider(),
          ])),
    );
  }

  static const List buisnessTnc = [
    "The Services are provided within normal working hours of the Company, which are 9:30 a.m. to 6:00 p.m. from Monday to Saturday, excluding public holidays. Unless otherwise agreed by the Company upon payment of surcharges, the Company does not normally perform the Services on Sundays or any public holiday.  Where the Services are not completed within the normal working hours on the dates stipulated in the quotation, the Company may upon the request of the Customer continue to perform the Services beyond the normal working hours for a surcharge or carry on the Services on subsequent dates to be agreed with the Customer at an extra charge.",
    "Any quotation submitted by the Company to provide the Services shall be open for acceptance for a period of 15 days following the submission thereof, and shall thereafter be deemed withdrawn. The Customer accepts the quotation by either signing and returning the acceptance form attached to the quotation, or by instructing the Company to perform the Services pursuant to the terms of the quotation. The quotation may be withdrawn by the Company prior to acceptance.  Any quotation is based upon the details provided to the Company by the Customer as regards the Goods and / or Fixtures and the Services requested by the Customer in relation thereto.  If any such detail provided by the Customer shall be incorrect, the Company may adjust its charges accordingly.",
    "Once accepted, the quotation and all the terms therein shall be binding. In so far as the term or terms of the quotation are inconsistent with the terms herein, the terms of the quotation shall prevail to the extent of the inconsistency. If the Customer wishes to cancel or terminate the Contract before its full performance by the Company, the Customer shall be liable to pay a cancellation or early termination charge in a sum specified in the quotation to compensate the Company for any loss it shall sustain by reason of such cancellation or early termination.  Such charge shall be without prejudice to any rights that the Company may have against the Customer in relation to such early termination.",
    "The Company, to the exclusion of the Customer, shall decide how the Services are to be provided, and may vary its decision from time to time.",
    "Any period of time within which the Company is to perform any part of the Services is an estimate only, and whilst the Company will use all reasonable endeavours to perform the Services at and within the agreed time, it shall not be liable for any loss or damage whatsoever (whether direct, indirect or consequential) arising from a failure to do so.",
    "The Customer shall ensure that adequate access is available to all relevant premises for the purpose of performing the Services.",
    "The Customer shall: (i) in respect of the Removal Services (a) promptly supply the Company with any information concerning the nature of the Goods which the Company may request; (b) in relation to the Goods, comply with all applicable laws, regulations and requirements relevant to the Company’s provision of the Removal Services; (ii) in respect of the Handyman Services (a) promptly supply the Company with any information concerning the Fixtures including their type, nature, structure, characteristics, dimensions, operational guides as to application and use (if any), and other information which in the opinion of the Company should be brought to the attention of the Company for the proper and efficient discharge of its duties in performing the Services. (b) In relation to the installation of the Fixtures, comply with all applicable laws, regulations and requirements relevant to the Company’s provision of the Handyman Services which comes at an agreed additional cost e.g. Carpentry, drilling, plumbing, DTH or other electrical and electronic equipment’s removal or fixing etc. (iii) in either case, not submit any Goods and / or Fixtures which are or include any dangerous, explosive, corrosive or other substance harmful to either person or the property of the Company or of others. The Customer agrees that if any Goods and / or Fixtures are submitted in contravention of this paragraph and loss or damage is thereby caused to the Company (whether directly or indirectly), the Customer will indemnify the Company against such loss or damage.",
    "While rendering relocation services the company excludes i) Split pickup/ multiple pickup and/or deliveries ii) Plant removals / Crating of Any Item if not mentioned in the respective quotation iii) Long carry, society/elevator charges and parking charges iv) vehicle detention, if any v) Storage in transit and any force majeure situation vi) any Government taxes or Octroi/ Mathadi /Toll / Entry Tax/Labor Union Charges in any state, if applicable vii) collection or delivery using stairs above 2nd floor (if service lift not provided) viii) special handling charges for items which cannot be accessed through elevator (hoisting/stair carry)",
    "Unpacking material and Debris shall be company property and therefore reserves rights to pick unpacking material. Unpacking Material shall be charged @ Rs. 100 per carton if retained by customer.",
    "The Company shall, as soon as is practical after receiving the Goods and / or Fixtures, provide the Customer with a packing list for validation. The list shall not specify or imply the contents of any closed container or warrant or imply that the Goods of Fixtures are in good, or any particular, state or condition.",
    "During any time that the Goods are stored at any Warehouse (except temporary storage in transit) the Company will allow the Customer access to the Warehouse during normal working hours for the purposes of checking the Goods, and identifying any particular Goods that it wishes to remove provided that: (i) the Customer gives the Company reasonable notice of his wish to inspect the Goods: (ii) at the time of delivery of the Goods to the Company, the Customer has registered one or more authorised signatories with the Company to whom access should be allowed; (iii) the person requesting access is, or appears to be from comparison of his signature with the specimen provided, an authorised signatory; (iv) the Customer pays the Company’s reasonable charges from time to time thereof. The Company shall not be liable for loss or damage arising from such access being permitted except to the extent that such loss arises as a result of the gross negligence or willful misconduct of the Company.",
    "When the Customer wants to recover the Goods or part of them from storage, it shall give the Company such period of notice as shall be specified by the Company from time to time. If less notice than is required by the Company is given, the Company will use all reasonable endeavours to retrieve and deliver the relevant Goods by the requested time but shall not be responsible for any loss or damage arising from any failure to do so.",
    "In consideration of the provision of the Services by the Company, the Customer shall pay to the Company:- (i) such charges for the Services as quoted in the quotation, or where there is no such quotation, such charges as calculated by reference to the Company’s scale of charges in force from time to time which scale is available for inspection upon request; and (ii) any out of pocket expenses incurred by the Company in the provision of the Services; and (iii) additional charges which are incurred by the Company by reason of the Customer having altered his instructions to the Company in relation to the Services; and (iv) reasonable charges for spare parts or replacement components where such parts or components are required and supplied by the Company to maintain the Fixtures in good working order.",
    "Notwithstanding any other remedy available to the Company, the Company shall have a lien over all Goods and / or Fixtures in its possession or under its control in respect of any sums due to the Company by the Customer. Notwithstanding that the Company shall have a lien over any Goods and / or Fixtures, the Customer shall continue to be liable for any and all charges arising from the provision of the Services until all sums due to the Company have been received by it. If the Company exercises its right of lien on the Goods and / or Fixtures and such lien is not discharged within three months, then the Company shall be irrevocably authorised to sell or otherwise dispose of all or any of the Goods and / or Fixtures subject to the lien and apply the proceeds in or towards payment of the sums due to the Company, without notice being required to be given to the Customer.",
    "The Customer warrants and undertake that all Goods and / or Fixtures in respect of which the Company is to provide the Services are either owned by the Customer or legally in its possession or under its control, and that the Customer is able to deal with the Goods and / or Fixtures as contemplated herein. The Customer agrees to indemnify the Company against any loss, damage or claim made against the Company arising from any lack of authority of the Customer to contract with the Company for the Services, or any breach of the warranty or undertaking given by the Customer under this paragraph.",
    "Notwithstanding anything to the contrary herein the Company shall in no event be liable (whether in negligence or under contract) for: (i) in respect of the Removal Services: (a) indirect, consequential or other loss arising from the Customer as a result of the Goods not being available to the Customer at any time for any reason; (b) loss or damage caused by any event of force majeure including, without limitation, storm, fire, flood, explosion, theft, acts done with malicious intent by any person, or any other event outside the control of the Company; (c) Loss or damage arising from the natural deterioration of the Goods; (d) Loss or damage arising from any act or omission of the Customer or any other person acting on the Customer’s behalf including a failure to declare or false declaration of value (and so that the Customer shall indemnify the Company accordingly); (e) Any other loss or damage of whatever nature, including but not limited to any loss of or damage to any internal parts of any object, unless the Customer is able to prove that the same is directly attributable to the negligence of the Company. In no case whatsoever shall the liability of the Company howsoever arising exceed USD 0.50 per pound per Article, or USD 2.00 per cube foot per Article, whichever is the greater, provided always that such liability shall not exceed the maximum value of the Article or such Article or part of the Goods which is lost or damaged. The Customer expressly agrees to take out insurance for additional cover in respect of any loss or damage which he may incur under this contract. (ii) In respect of the Handyman Services : (a) any design defect in, or malfunction due to faulty materials or workmanship, of the Fixtures whether or not such defect or malfunction is apparent or known to the Company; (b) any neglect, misuse or error or omission relating to the operation of the Fixtures by the Customer; (c) any modification, adjustment or repair to the Fixtures made by the Customer or a third party whether or not such modification, adjustment or repair is apparent or known to the Company; (d) normal wear and tear of the Fixtures, subjection of the Fixtures to unusual physical or electrical stress or any failure or fluctuation of electrical power; (e) loss or damage caused by any event of force majeure including, without limitation, storm, fire, flood, explosion, theft, acts done with malicious intent by any person, or any other event outside the control of the Company; (f) failure on the part of the Customer to comply with his obligations under Clause 9 (ii) herein; (g) any other cause of whatever nature unless the Customer is able to prove that the same is directly attributable to the negligence of the Company. In all other cases, the liability of the Company to the Customer in respect of any loss or damage he may incur under this Contract shall be limited to the total amount of charges payable by the Customer under the quotation. (iii) In either case, nothing in these conditions shall, or shall be deemed to, exclude or limit the liability of the Company for a negligent act or omission resulting in the death of, or personal injury to, any party to whom the Company owes a duty of care, save to the extent that such limitation or exclusion is permissible by law.",
    "These conditions shall continue for as long as the Company is providing the Customer with any of the Services. The Company may however, upon 7 days’ written notice require the Customer to remove any Goods and / or Fixtures being stored by it from any Warehouse and, if the Customer fails to designate a place for alternative storage, deliver the same to the Customer at the premises from which they were originally collected.",
    "The Insurance does not cover loss or damage arising out of the acts of government, customs authority or official confiscation. It also does not cover loss/damage of the goods packed by owner and or Jewellery/cash, deeds, traveler’s cheque, plants, gas cylinders, alcoholic beverages, contraband or other restricted items.",
    "Internal damages of any kind are also not covered under Insurance Coverage unless there are signs of external physical damage. Any external damage must be noted on the packing inventory on the day of delivery. This pertains to any and all electronic items, i.e. computers, speakers, etc. However, electrical or mechanical malfunctioning coverage, excluding automobiles, is available and can be taken in writing at an additional premium of 2%.",
    "In event of international or inter-continental moves, the Company shall not be under any liability in respect of any claim arising out of or in connections with the loss of or damage to any Goods and or Fixtures unless: (i) a claim in writing is received by the Company within 15 (Fifteen) working days from the date the Customer becomes, or reasonably should become, aware of the occurrence of the loss or damage; or if the claim arises from non-delivery or short delivery, at the time when delivery ought to have been made; (ii) Claim in automobile must be reported within a 7 (Seven) working time of vehicle delivery.",
    "In event of domestic or local moves, the Company shall not be under any liability in respect of any claim arising out of or in connections with the loss of or damage to any Goods and or Fixtures unless: (i) a claim in writing is received by the Company within two days from the date the Customer becomes, or reasonably should become, aware of the occurrence of the loss or damage; or if the claim arises from non-delivery or short delivery, at the time when delivery ought to have been made; (ii) Claim in automobile must be reported within twelve hours of vehicle delivery.",
    "Where there has been a failure to comply with any of the aforementioned time limits, the claim shall be deemed to have been waived and shall be absolutely barred.",
    "No liability for damage to Goods and / or Fixtures will be accepted by the Company unless the Company has been given a reasonable opportunity to inspect such damage. Claims if any, which have been lodged in writing would be entertained by the third-party insurance agent and not the company, under any circumstances.",
    "The Customer undertakes that no claim shall be made against any servant or agent of the Company which imposes or attempts to impose upon him any liability whatsoever in connection with the Services and, if any such claim should nevertheless be made, to indemnify the Company against all consequences thereof. Without prejudice to the foregoing, all such servants or agents shall have the benefit of all provisions herein as if such provisions were expressly for their benefit. In entering into any contract incorporating these conditions, the Company, to the extent of those provisions does so not only on its behalf but as agent and trustee for such servants and agents.",
    "Payment needs to be done prior to packing / dispatch by cheque / credit card with card fee as applicable. As a special case credit till the time of delivery can be given with terms and conditions. In any case if the payment is not cleared before delivery the company reserves the right to withhold the delivery till the complete payment is received.",
    "If any of these conditions or any part thereof shall, in any case, be held to be invalid or to have failed the test of reasonableness within the meaning of the Control of Exemption Clauses Ordinance, such term or provision shall be deemed to be severed as if such term or provision had not been contained herein but without affecting the remaining conditions.",
    "Work undertaken as a result of this quotation will be done on the basis of the Indian Contract Act, 1872. Multiple pick-ups and deliveries are not included except as specified. While every care is taken during the packing, transit risks should be covered by insurance. In the absence of insurance cover, the goods are deemed to be self-insured by you.",
  ];

  static const List otherTNC = [
    {
      "title": "T&C Pertaining to the Website",
      "tnc": [
        "Please read the terms of use carefully before using or registering on the website or accessing any material, information or services through the website. Your use of the website or the services provided by the website shall signify your acceptance of the terms of use and your agreement to be legally bound by the same.",
        "Unless otherwise stated, GoFlexe and / or its licensors own the intellectual property rights in the website and material on the website. Subject to the license below, all these intellectual property rights are reserved.",
        "You may view, download for caching purposes only, and print pages (or other content) from the website for your own personal use, subject to the restrictions set out below and elsewhere in these terms and conditions.",
        "You can contact us by email at admin@goflexe.com"
      ]
    },
    {
      "title": "ACCEPTABLE USE :",
      "tnc": [
        "You must not use this website in any way that causes, or may cause, damage to the website or impairment of the availability or accessibility of the website; or in any way which is unlawful, illegal, fraudulent or harmful, or in connection with any unlawful, illegal, fraudulent or harmful purpose or activity.",
        "You must not use this website to copy, store, host, transmit, send, use, publish or distribute any material which consists of (or is linked to) any spyware, computer virus, Trojan horse, worm, keystroke logger, rootkit or other malicious computer software.",
        "You must not conduct any systematic or automated data collection activities (including without limitation scraping, data mining, data extraction and data harvesting) on or in relation to this website without GoFlexe’s express written consent.",
        "You must not use this website to transmit or send unsolicited commercial communications."
      ]
    },
    {
      "title": "RESTRICTED ACCESS :",
      "tnc": [
        "[Access to certain areas of this website is restricted.] GoFlexe reserves the right to restrict access to secure areas of this website, or indeed this entire website, at GoFlexe’s discretion.",
        "If GoFlexe provides you with a user ID and password to enable you to access restricted areas of this website or other content or services, you must ensure that the user ID and password are kept confidential.",
        "GoFlexe may disable your user ID and password in its sole discretion without notice or explanation."
      ]
    },
    {
      "title": "USER CONTENT :",
      "tnc": [
        "In these terms and conditions, “your user content” means material (including without limitation text, images, audio material, video material and audio-visual material) that you submit to this website, for whatever purpose.",
        "Your user content must not be illegal or unlawful, must not infringe any third party’s legal rights, and must not be capable of giving rise to legal action whether against you or GoFlexe or a third party (in each case under any applicable law).",
        "You must not submit any user content to the website that is or has ever been the subject of any threatened or actual legal proceedings or other similar complaint.",
        "GoFlexe reserves the right to edit or remove any material submitted to this website, or stored on GoFlexe’s servers, or hosted or published upon this website.",
        "Notwithstanding GoFlexe’s rights under these terms and conditions in relation to user content, We do not undertake to monitor the submission of such content to, or the publication of such content on, this website."
      ]
    },
    {
      "title": "NO WARRANTIES :",
      "tnc": [
        "This website is provided “as is” without any representations or warranties, express or implied. GoFlexe makes no representations or warranties in relation to this website or the information and materials provided on this website."
      ]
    },
    {
      "title": "LIMITATIONS OF LIABILITY :",
      "subtitle":
          "GoFlexe will not be liable to you (whether under the law of contact, the law of torts or otherwise) in relation to the contents of, or use of, or otherwise in connection with, this website:",
      "tnc": [
        "to the extent that the website is provided free-of-charge, for any direct loss;",
        "for any indirect, special or consequential loss; or",
        "for any business losses, loss of revenue, income, profits or anticipated savings, loss of contracts or",
        "business relationships, loss of reputation or goodwill, or loss or corruption of information or data.",
        "These limitations of liability apply even if GoFlexe has been expressly advised of the potential loss."
      ]
    },
    {
      "title": "EXCEPTIONS :",
      "subtitle":
          "Nothing in this website disclaimer will exclude or limit any warranty implied by law that it would be unlawful to exclude or limit; and nothing in this website disclaimer will exclude or limit GoFlexe’s liability in respect of any:",
      "tnc": [
        "fraud or fraudulent misrepresentation on the part of GoFlexe; or",
        "matter which it would be illegal or unlawful for [NAME] to exclude or limit, or to attempt or purport to exclude or limit, its liability."
      ]
    },
    {
      "title": "REASONABLENESS :",
      "tnc": [
        "By using this website, you agree that the exclusions and limitations of liability set out in this website disclaimer are reasonable. If you do not think they are reasonable, you must not use this website."
      ]
    },
    {
      "title": "OTHER PARTIES :",
      "tnc": [
        "You accept that, as a limited liability entity, GoFlexe has an interest in limiting the personal liability of its officers and employees. You agree that you will not bring any claim personally against GoFlexe’s officers or employees in respect of any losses you suffer in connection with the website.",
        "[Without prejudice to the foregoing paragraph,] you agree that the limitations of warranties and liability set out in this website disclaimer will protect GoFlexe’s officers, employees, agents, subsidiaries, successors, assigns and sub-contractors as well as GoFlexe."
      ]
    },
    {
      "title": "VARIATION :",
      "tnc": [
        "GoFlexe may revise these terms and conditions from time-to-time. Revised terms and conditions will apply to the use of this website from the date of the publication of the revised terms and conditions on this website. Please check this page regularly to ensure you are familiar with the current version."
      ]
    },
    {
      "title": "SEVERABILITY :",
      "tnc": [
        "If a provision of these terms and conditions is determined by any court or other competent authority to be unlawful and/or unenforceable, the other provisions will continue in effect. If any unlawful and/or unenforceable provision would be lawful or enforceable if part of it were deleted, that part will be deemed to be deleted, and the rest of the provision will continue in effect. Entire agreement",
        "These terms and conditions [, together with [DOCUMENTS],] constitute the entire agreement between you and GoFlexe in relation to your use of this website, and supersede all previous agreements in respect of your use of this website."
      ]
    },
    {
      "title": "LAW AND JURISDICTION :",
      "tnc": [
        "These terms and conditions will be governed by and construed in accordance with [GOVERNING LAW], and any disputes relating to these terms and conditions will be subject to the [non-]exclusive jurisdiction of the courts of New Delhi [India]."
      ]
    },
  ];
}

//http://www.packmoverelocate.com/terms-conditions/
